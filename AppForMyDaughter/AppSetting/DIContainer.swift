//
//  DIContainer.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 25.05.2024.
//

class DIContainer {
    
    static let shared = DIContainer()
    private init() {}
    
    func makeOpenAIService() -> OpenAIServiceProtocol {
        let apiKey = ""
        let systemMessage = "Ты мой ассистент"
        let model: OpenAIChatService.GptModel = .gpt4o
        return OpenAIChatService(model: model, apiKey: apiKey, systemMessage: systemMessage)
    }
}
