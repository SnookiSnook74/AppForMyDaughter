//
//  DIContainer.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 25.05.2024.
//

import Foundation

class DIContainer {
    
    static let shared = DIContainer()
    private init() {}
    
    func makeOpenAIService() -> OpenAIServiceProtocol {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            fatalError("API Key not found")
        }
        let systemMessage = "Ты мой ассистент"
        let model: OpenAIChatService.GptModel = .gpt4o
        return OpenAIChatService(model: model, apiKey: apiKey, systemMessage: systemMessage)
    }
}
