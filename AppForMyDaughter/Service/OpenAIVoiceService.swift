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

class OpenAIVoiceService: NSObject, OpenAIVoiceServiceProtocol, AVAudioPlayerDelegate {

    var urlSession = URLSession.shared

    private let model: String
    private let voice: Voice
    private let apiKey: String
    private var audioPlayer: AVAudioPlayer?
    private var audioQueue: [Data] = []
    private var isPlaying = false

    var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/audio/speech")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }

    init(model: String = "tts-1", voice: Voice, apiKey: String) {
        self.model = model
        self.voice = voice
        self.apiKey = apiKey
        super.init()
    }

    func speak(text: String) async throws {
        let sentences = text.split { ".!?".contains($0) }.map { String($0).trimmingCharacters(in: .whitespaces) }

        for sentence in sentences {
            let requestBody: [String: Any] = [
                "model": model,
                "input": sentence,
                "voice": voice.rawValue
            ]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
                throw OpenAIVoiceServiceError.serializationError
            }

            var request = urlRequest
            request.httpBody = jsonData

            do {
                let (data, response) = try await urlSession.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw OpenAIVoiceServiceError.invalidResponse
                }

                audioQueue.append(data)
                if !isPlaying {
                    playNextAudio()
                }
            } catch {
                throw OpenAIVoiceServiceError.networkError(error)
            }
        }
    }

    private func playNextAudio() {
        guard !audioQueue.isEmpty else {
            isPlaying = false
            return
        }

        isPlaying = true
        let data = audioQueue.removeFirst()

        do {
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("speech.mp3")
            try data.write(to: tempURL)
            audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            isPlaying = false
            print(OpenAIVoiceServiceError.audioPlaybackError(error).localizedDescription)
            playNextAudio()
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextAudio()
    }
}

extension OpenAIVoiceService {

    /// Ошибки связанные с OpenAIVoiceService
    enum OpenAIVoiceServiceError: LocalizedError, CustomStringConvertible  {
        case serializationError
        case networkError(Error)
        case invalidResponse
        case audioPlaybackError(Error)

        var description: String {
            switch self {
            case .serializationError:
                return "Ошибка серилизации данных."
            case .networkError(let error):
                return "Ошибка сети: \(error.localizedDescription)"
            case .invalidResponse:
                return "Неверный ответ сервера."
            case .audioPlaybackError(let error):
                return "Ошибка воспроизведения аудио: \(error.localizedDescription)"
            }
        }

        var errorDescription: String? {
            return description
        }
    }
}

extension OpenAIVoiceService {

    /// Список голосов
    enum Voice: String {
        case alloy
        case echo
        case fable
        case onyx
        case nova
        case shimmer
    }
}
