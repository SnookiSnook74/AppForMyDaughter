//
//  PresenterLayerAssembler.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 29.06.2024.
//

import Foundation

// Сборщик зависимостей презентационного слоя
class PresenterLayerAssembler {
    
    func registerViewModels(in container: DIContainer) {
        container.register(StartViewModel.self) {
            guard let openAIUseCase = container.resolve(OpenAIChatUseCase.self),
                  let voiceUseCase = container.resolve(OpenAIVoiceUseCase.self) else {
                fatalError("UseCases не зарегистрированы в DIContainer")
            }
            return StartViewModel(chatAIUseCase: openAIUseCase, voiceUseCase: voiceUseCase)
        }
    }
}
