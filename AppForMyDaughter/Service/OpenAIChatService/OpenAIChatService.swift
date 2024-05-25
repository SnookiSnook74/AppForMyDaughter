//
//  ChatRequest.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 19.05.2024.
//

import Foundation


/// Протокол для сервиса сообщений OpenAI
protocol OpenAIServiceProtocol {
    
    /// Отправка не стриминоговых сообщений
    func sendMessage(text: String) async throws -> String
    
    /// Отправка сообщений в режиме стриминга
    func sendMessageWithStream(text: String) async throws -> AsyncThrowingStream<String, Error>
}

class OpenAIChatService: OpenAIServiceProtocol {
    
    private let systemMessage: String
    private let model: String
    private let apiKey: String
    
    var urlSession = URLSession.shared
    private var historyList:[History]
    
    var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequset = URLRequest(url: url)
        urlRequset.httpMethod = "POST"
        urlRequset.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequset.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return urlRequset
    }
    
    init(model: GptModel, apiKey: String, systemMessage: String, historyList: [History]) {
        self.systemMessage = systemMessage
        self.model = model.description
        self.apiKey = apiKey
        self.historyList = historyList
    }
    
    func sendMessage(text: String) async throws -> String {
        
        historyList.append(History(role: "user", content: text))
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": historyList.map { ["role": $0.role, "content": $0.content] }
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            
            var requset = urlRequest
            requset.httpBody = jsonData
            
            let (data, response) =  try await urlSession.data(for: requset)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw OpenAIServiceError.httpResponseError((response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            
            let jsonDecoder = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            if let message = jsonDecoder.choices.first?.message.content {
                historyList.append(History(role: "assistant", content: message))
                return message
            } else {
                throw OpenAIServiceError.messageEmpty
            }
            
        } catch {
            throw OpenAIServiceError.serializationError(error.localizedDescription)
        }
    }
    
    func sendMessageWithStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        var request = urlRequest
        
        historyList.append(History(role: "user", content: text))
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": historyList.map { ["role": $0.role, "content": $0.content] },
            "stream": true
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (result, response) = try await urlSession.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIServiceError.httpResponseError(-1)
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var errorText = ""
            for try await line in result.lines {
                errorText += line
            }
            throw OpenAIServiceError.httpResponseError(httpResponse.statusCode)
        }
        
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
        case httpResponseError(Int)
        case messageEmpty
        
        var description: String {
            switch self {
            case .serializationError(let messages):
                return "Ошибка в Serialization \(messages)"
            case .httpResponseError(let statusCode):
                return "Ошибка в ответе от сервера \(statusCode)"
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
