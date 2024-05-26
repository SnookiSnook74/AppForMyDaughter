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
        let chatService = OpenAIChatService(model: .gpt4o, apiKey: apiKey, systemMessage: systemMessage)
        chatService.urlSession = ProxyService.createProxySession()
        return chatService
    }
    
    func makeOpenAIVoice() -> OpenAIVoiceServiceProtocol {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            fatalError("API Key not found")
        }
        let voiceService = OpenAIVoiceService(voice: .shimmer, apiKey: apiKey)
        voiceService.urlSession = ProxyService.createProxySession()
        return voiceService
    }
    
}
