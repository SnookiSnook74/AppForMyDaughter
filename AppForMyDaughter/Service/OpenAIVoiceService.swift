//
//  OpenAIVoiceService.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 25.05.2024.
//

import Foundation
import AVFoundation

protocol OpenAIVoiceServiceProtocol {
    func speak(text: String) async throws
}

class OpenAIVoiceService: OpenAIVoiceServiceProtocol {
    
    var urlSession = URLSession.shared
    
    private let model: String
    private let voice: String
    private let apiKey: String
    private var audioPlayer: AVAudioPlayer?
    
    var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/audio/speech")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    init(model: String = "tts-1", voice: String = "alloy", apiKey: String) {
        self.model = model
        self.voice = voice
        self.apiKey = apiKey
        
        /// Опционально для скрытия запроса
        self.urlSession = ProxyService.createProxySession()
    }
    
    func speak(text: String) async throws {
        
        let requestBody: [String: Any] = [
            "model": model,
            "input": text,
            "voice": voice
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            fatalError("Ошибка серилизации")
        }
        
        var request = urlRequest
        request.httpBody = jsonData
        
        let (data, _) = try await urlSession.data(for: request)
        
        try playAudio(data: data)
    }
    
    private func playAudio(data: Data) throws {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("speech.mp3")
        
        do {
            try data.write(to: tempURL)
            audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Ошибка воспроизведения аудио: \(error.localizedDescription)")
            throw error
        }
    }
}
