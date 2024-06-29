//
//  OpenAIAudioToTextServiceUseCase.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 29.06.2024.
//

import Foundation

class OpenAIAudioToTextServiceUseCase {
    
    let transcriptionService: OpenAIAudioToTextServiceProtocol
    
    init(transcriptionService: OpenAIAudioToTextServiceProtocol) {
        self.transcriptionService = transcriptionService
    }
    
    func transcription(fileUrl: URL) async throws -> String {
      try await transcriptionService.transcribeAudio(fileURL: fileUrl)
    }
    
}
