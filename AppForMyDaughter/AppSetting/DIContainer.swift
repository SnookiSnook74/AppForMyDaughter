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
            let systemMessage = "Ты рассказчик сказок"
            let chatService = OpenAIChatService(model: .gpt4o, apiKey: apiKey, systemMessage: systemMessage)
            chatService.historyList.append(History(role: "assistant", content: "Мы с дочерью отправляемся в вымышленные приключения в стиле Dungeons & Dragons (DND). Наши приключения начинаются в величественном замке, которым правит мудрый король. Король дает нам задания и отправляет нас в удивительные путешествия.В замке живет Вильям, сын короля, который является напарником моей дочери Таисии. Вильям — храбрый и умный принц, всегда готовый к новым вызовам и приключениям.Кроме того, в замке живут Великан и Халк. Великан обладает огромной силой и добрым сердцем, он всегда готов помочь в трудную минуту. Халк — зеленый гигант с невероятной мощью, который может справиться с любыми препятствиями на нашем пути.Твоя задача — выполнять роль мастера игры в DND, придумывать для нас увлекательные приключения, полные загадок, тайн и волшебства. Каждое утро король будет собирать нас в тронном зале и объявлять новое задание. Мы будем путешествовать по волшебным мирам, сражаться с монстрами, находить сокровища и решать сложные задачи.Создай для нас незабываемые истории и помоги нам пережить захватывающие моменты в нашем волшебном мире приключений! Но старайся давать нам чаще выбирать ход истории."))
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
