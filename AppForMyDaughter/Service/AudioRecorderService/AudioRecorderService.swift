//
//  AudioRecorderService.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 15.09.2024.
//

import Foundation
import AVFoundation

/// Протокол сервиса для записи аудио
protocol AudioRecorderServiceProtocol {
    
    /// Метод для начала записи аудио
    /// - Throws: Ошибка при запуске записи или отсутствующее разрешение на доступ к микрофону
    func startRecording() async throws
    
    /// Метод для остановки записи аудио
    /// - Returns: URL, по которому сохранено записанное аудио.
    /// - Throws: Ошибка при завершении записи.
    func stopRecording() throws -> URL
    
    /// Метод для получения текущего состояния записи
    /// - Returns: `true`, если запись продолжается, иначе `false`.
    func isRecording() -> Bool
}

class AudioRecorderService: NSObject, AudioRecorderServiceProtocol, AVAudioRecorderDelegate {
    
    private var audioRecorder: AVAudioRecorder?
    private var audioFilename: URL?
    
    override init() {
        super.init()
    }
    
    func startRecording() async throws {
        // Запрашиваем разрешение на использование микрофона
        let audioSession = AVAudioSession.sharedInstance()
        
        // Запрашиваем разрешение на доступ к микрофону
        try audioSession.setCategory(.playAndRecord, mode: .default)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Проверяем наличие разрешения на использование микрофона
        if await AVAudioApplication.requestRecordPermission() {
            do {
                try self.beginRecording()
            } catch {
                print("Не удалось начать запись: \(error.localizedDescription)")
            }
        }
    }
    
    /// Метод для остановки записи аудио
    func stopRecording() throws -> URL {
        guard let recorder = audioRecorder, recorder.isRecording else {
            throw AudioRecorderError.notRecording
        }
        
        recorder.stop()
        audioRecorder = nil
        
        guard let audioFilename = audioFilename else {
            throw AudioRecorderError.failedToRetrieveFile
        }
        
        return audioFilename
    }
    
    /// Метод для получения текущего состояния записи
    func isRecording() -> Bool {
        return audioRecorder?.isRecording ?? false
    }
}

private extension AudioRecorderService {
    
    private func beginRecording() throws {
        // Определяем место для сохранения аудиофайла
        let directory = FileManager.default.temporaryDirectory
        let filename = UUID().uuidString + ".m4a"
        audioFilename = directory.appendingPathComponent(filename)
        
        // Настройки для записи аудио
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        guard let audioFilename = audioFilename else {
            throw AudioRecorderError.failedToCreateFileURL
        }
        
        audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
    }
    
    /// Ошибки связанные с AudioRecorderService
    enum AudioRecorderError: LocalizedError {
        case failedToCreateFileURL
        case failedToRetrieveFile
        case notRecording
        
        var errorDescription: String? {
            switch self {
            case .failedToCreateFileURL:
                return "Не удалось создать URL для сохранения аудиофайла."
            case .failedToRetrieveFile:
                return "Не удалось получить URL сохранённого аудиофайла."
            case .notRecording:
                return "Запись не ведётся."
            }
        }
    }
}
