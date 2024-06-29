//
//  OpenAIChatUseCase.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 29.06.2024.
//

import Foundation

class OpenAIChatUseCase {
    
    let chatService: OpenAIServiceProtocol
    
    init(chatService: OpenAIServiceProtocol) {
        self.chatService = chatService
    }
    
    func sendStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        try await chatService.sendMessageWithStream(text: text)
    }
    
    func sendNoStreamMessage(text: String) async throws -> String {
        try await chatService.sendMessage(text: text)
    }
}
