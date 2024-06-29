//
//  OpenAIChatServiceModel.swift
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

/// Структура для храненения стримингового ответа
struct ChatCompletionChunk: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let delta: Delta
        
        struct Delta: Codable {
            let content: String?
        }
    }
}
