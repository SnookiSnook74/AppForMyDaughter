//
//  OpenAIAudioToTextService.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 29.06.2024.
//

import Foundation
import AVFoundation

/// Протокол сервиса для превращения аудо в текст
protocol OpenAIAudioToTextServiceProtocol {
    
    /// Метод для обработки аудио
    /// - Parameter fileURL: URL аудиофайла для транскрипции.
    /// - Throws: Ошибка сети или ошибки, связанные с обработкой ответа.
    /// - Returns: Распознанный текст из аудиофайла.
    func transcribeAudio(fileURL: URL) async throws -> String
}

class OpenAIAudioToTextService: NSObject, OpenAIAudioToTextServiceProtocol {

    var urlSession = URLSession.shared

    private let model: String
    private let apiKey: String

    var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }

    init(model: String = "whisper-1", apiKey: String) {
        self.model = model
        self.apiKey = apiKey
        super.init()
    }

    func transcribeAudio(fileURL: URL) async throws -> String {
        var request = urlRequest

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        let filename = fileURL.lastPathComponent
        let mimetype = "audio/m4a"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(try Data(contentsOf: fileURL))
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"model\"\r\n\r\n")
        body.appendString("\(model)\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        request.httpBody = body as Data

        do {
            let data: Data = try await NetworkService.shared.sendRequest(request)
            
            guard let responseData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let text = responseData["text"] as? String else {
                throw OpenAIAudioToTextServiceError.serializationError
            }
            
            return text
        } catch {
            throw OpenAIAudioToTextServiceError.networkError(error)
        }
    }
}

extension OpenAIAudioToTextService {

    /// Ошибки связанные с OpenAIAudioToTextService
    enum OpenAIAudioToTextServiceError: LocalizedError, CustomStringConvertible  {
        case serializationError
        case networkError(Error)
        case invalidResponse

        var description: String {
            switch self {
            case .serializationError:
                return "Ошибка серилизации данных."
            case .networkError(let error):
                return "Ошибка сети: \(error.localizedDescription)"
            case .invalidResponse:
                return "Неверный ответ сервера."
            }
        }

        var errorDescription: String? {
            return description
        }
    }
}

private extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            append(data)
        }
    }
}
