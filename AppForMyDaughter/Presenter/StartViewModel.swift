//
//  StartViewModel.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 16.06.2024.
//

import Foundation
import Observation

class StartViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    private let chatAIUseCase: OpenAIChatUseCase
    private let voiceUseCase: OpenAIVoiceUseCase

    init(chatAIUseCase: OpenAIChatUseCase, voiceUseCase: OpenAIVoiceUseCase) {
        self.chatAIUseCase = chatAIUseCase
        self.voiceUseCase = voiceUseCase
    }

    func sendButtonTapped() {
        guard !inputText.isEmpty else { return }
        sendMessage(inputText)
        inputText = ""
    }

    private func sendMessage(_ text: String) {
        Task {
            do {
                let stream = try await chatAIUseCase.sendStream(text: text)
                
                var accumulatedText = ""
                
                for try await chunk in stream {
                    print("Received chunk: \(chunk)")
                    accumulatedText += chunk
                    
                    if accumulatedText.contains(where: { ".!?".contains($0) }) {
                        try await voiceUseCase.speak(text: accumulatedText)
                        accumulatedText = ""
                    }
                }
                
                if !accumulatedText.isEmpty {
                    print("Final accumulated text: \(accumulatedText)")
                    try await voiceUseCase.speak(text: text)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
