//
//  ChatRequest.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 19.05.2024.
//

import Foundation

/// Структура для хранения истории собщений
struct History {
    let role: String
    let content: String
}

/// Структура для декодирования ответа от OpenAI
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let role: String
            let content: String
        }
    }
}

/// Протокол для сервиса сообщений OpenAI
protocol OpenAIServiceProtocol {
    
    /// Отправка не стриминоговых сообщений
    func sendMessage(text: String) async throws -> String
}

class OpenAIService: OpenAIServiceProtocol {
    
    private let systemMessage: String
    private let model: String
    private let apiKey: String
    
    private let urlSession = URLSession.shared
    private var historyList:[History]
    
    var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequset = URLRequest(url: url)
        urlRequset.httpMethod = "POST"
        urlRequset.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequset.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return urlRequset
    }
    
    init(model: String, apiKey: String, systemMessage: String, historyList: [History]) {
        self.systemMessage = systemMessage
        self.model = model
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
                historyList.append(History(role: "assistent", content: message))
                return message
            } else {
                throw OpenAIServiceError.messageEmpty
            }
            
        } catch {
            throw OpenAIServiceError.serializationError(error.localizedDescription)
        }
    }
}

/// Обработка ошибок сервиса
extension OpenAIService {
    
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
