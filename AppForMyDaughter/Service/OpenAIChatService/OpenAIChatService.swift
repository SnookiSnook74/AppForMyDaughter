//
//  ChatRequest.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 19.05.2024.
//

import Foundation


/// Протокол для сервиса сообщений OpenAI
protocol OpenAIServiceProtocol {
    
    /// Метод для обработки текста пользователя
    /// - Parameter text: запрос пользователя к OpenAI.
    /// - Throws: Ошибка сети или ошибки, связанные с обработкой ответа.
    /// - Returns: Ответ от сервера OpenAI.
    func sendMessage(text: String) async throws -> String
    
    /// Метод для стриминговой обработки текста пользователя
    /// - Parameter text: запрос пользователя к OpenAI.
    /// - Throws: Ошибка сети или ошибки, связанные с обработкой ответа.
    /// - Returns: Ответ от сервера OpenAI в режиме стриминга (ответ приходит по частям).
    func sendMessageWithStream(text: String) async throws -> AsyncThrowingStream<String, Error>
}

class OpenAIChatService: OpenAIServiceProtocol {
    
    private let systemMessage: String
    private let model: GptModel
    private let apiKey: String
    
    var historyList:[History] = []
    
    var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequset = URLRequest(url: url)
        urlRequset.httpMethod = "POST"
        urlRequset.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequset.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return urlRequset
    }
    
    init(model: GptModel, apiKey: String, systemMessage: String) {
        self.systemMessage = systemMessage
        self.model = model
        self.apiKey = apiKey
    }
    
    func sendMessage(text: String) async throws -> String {
        historyList.append(History(role: "user", content: text))
        
        let requestBody: [String: Any] = [
            "model": model.description,
            "messages": historyList.map { ["role": $0.role, "content": $0.content] }
        ]
        
        var request = urlRequest
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let response: OpenAIResponse = try await NetworkService.shared.sendRequest(request, decodingType: OpenAIResponse.self)
        
        if let message = response.choices.first?.message.content {
            historyList.append(History(role: "assistant", content: message))
            return message
        } else {
            throw OpenAIServiceError.messageEmpty
        }
    }
    
    func sendMessageWithStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        var request = urlRequest
        
        historyList.append(History(role: "user", content: text))
        
        let requestBody: [String: Any] = [
            "model": model.description,
            "messages": historyList.map { ["role": $0.role, "content": $0.content] },
            "stream": true
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (result, _) = try await NetworkService.shared.sendRequestForStream(request)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var responseText = ""
                    for try await line in result.lines {
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let decodeData = try? JSONDecoder().decode(ChatCompletionChunk.self, from: data),
                           let text = decodeData.choices.first?.delta.content
                        {
                            responseText += text
                            continuation.yield(text)
                        }
                    }
                    historyList.append(History(role: "assistant", content: responseText))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

/// Обработка ошибок сервиса
extension OpenAIChatService {
    
    enum OpenAIServiceError: LocalizedError, CustomStringConvertible {
        case serializationError(String)
        case messageEmpty
        
        var description: String {
            switch self {
            case .serializationError(let messages):
                return "Ошибка в Serialization \(messages)"
            case .messageEmpty:
                return "Пришло пустое сообщение или ответ не пришел вовсе"
            }
        }
        
        var errorDescription: String? {
            return description
        }
    }
}

extension OpenAIChatService {
    
    /// Виды моделей
    enum GptModel: String {
        case gpt4o = "gpt-4o"
        case gpt4 = "gpt-4-turbo"
        case gpt3_5 = "gpt-3.5-turbo-0125"
        
        var description: String {
            return self.rawValue
        }
    }
}
