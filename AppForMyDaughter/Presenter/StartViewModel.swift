//
//  StartViewModel.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 16.06.2024.
//

import Foundation
import Observation

@MainActor
class StartViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    var openAI: OpenAIServiceProtocol
    var voiceService: OpenAIVoiceServiceProtocol?

    init(openAI: OpenAIServiceProtocol, voiceService: OpenAIVoiceServiceProtocol?) {
        self.openAI = openAI
        self.voiceService = voiceService
    }

    func sendButtonTapped() {
        guard !inputText.isEmpty else { return }
        sendMessage(inputText)
        inputText = ""
    }

    private func sendMessage(_ text: String) {
        Task {
            do {
                let stream = try await openAI.sendMessageWithStream(text: text)
                
                var accumulatedText = ""
                
                for try await chunk in stream {
                    print("Received chunk: \(chunk)")
                    accumulatedText += chunk
                    
                    if accumulatedText.contains(where: { ".!?".contains($0) }) {
                        try await voiceService?.speak(text: accumulatedText)
                        accumulatedText = ""
                    }
                }
                
                if !accumulatedText.isEmpty {
                    print("Final accumulated text: \(accumulatedText)")
                    try await voiceService?.speak(text: accumulatedText)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
