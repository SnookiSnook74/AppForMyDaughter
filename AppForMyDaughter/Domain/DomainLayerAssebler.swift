//
//  DomainLayerAssebler.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 29.06.2024.
//

import Foundation

/// Сборщик зависимостей доменного слоя
class DomainLayerAssebler {
    
   func registerUseCases(in container: DIContainer) {
        container.register(OpenAIVoiceUseCase.self) {
            guard let voiceService = container.resolve(OpenAIVoiceServiceProtocol.self) else {
                fatalError("OpenAIVoiceServiceProtocol не зарегистрирован")
            }
            return OpenAIVoiceUseCase(voiceService: voiceService)
        }
        
       container.register(OpenAIChatUseCase.self) {
            guard let chatService = container.resolve(OpenAIServiceProtocol.self) else {
                fatalError("OpenAIChatService не зарегистрирован")
            }
            return OpenAIChatUseCase(chatService: chatService)
        }
       
       container.register(OpenAIAudioToTextServiceUseCase.self) {
           guard let transcription = container.resolve(OpenAIAudioToTextServiceProtocol.self) else {
               fatalError("OpenAIAudioToTextService не зарегистрирован")
           }
           return OpenAIAudioToTextServiceUseCase(transcriptionService: transcription)
       }
    }
}
