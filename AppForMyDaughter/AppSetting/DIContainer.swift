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
    
    private var factories = [String: () -> Any]()
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = "\(type)"
        factories[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        guard let factory = factories[key] else { return nil }
        return factory() as? T
    }
}

extension DIContainer {
    
    func registerServices() {
        register(OpenAIServiceProtocol.self) {
            guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
                fatalError("API Key not found")
            }
            let systemMessage = "Ты мой ассистент"
            let chatService = OpenAIChatService(model: .gpt4o, apiKey: apiKey, systemMessage: systemMessage)
            chatService.urlSession = ProxyService.createProxySession()
            return chatService
        }
        
        register(OpenAIVoiceServiceProtocol.self) {
            guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
                fatalError("API Key not found")
            }
            let voiceService = OpenAIVoiceService(voice: .shimmer, apiKey: apiKey)
            voiceService.urlSession = ProxyService.createProxySession()
            return voiceService
        }
    }
}
