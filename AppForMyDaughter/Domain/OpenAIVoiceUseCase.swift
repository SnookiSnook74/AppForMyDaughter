//
//  OpenAIVoiceUseCase.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 29.06.2024.
//

import Foundation

class OpenAIVoiceUseCase {
    
    let voiceService: OpenAIVoiceServiceProtocol
    
    init(voiceService: OpenAIVoiceServiceProtocol) {
        self.voiceService = voiceService
    }
    
    func speak(text: String) async throws {
        try await voiceService.speak(text: text)
    }
}
