//
//  AppForMyDaughter.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 16.06.2024.
//

import SwiftUI

@main
struct AppForMyDaughterApp: App {
    
    @StateObject private var startViewModel: StartViewModel

    init() {
        DIContainer.shared.registerServices()
        
        let openAIService = DIContainer.shared.resolve(OpenAIServiceProtocol.self)!
        let voiceService = DIContainer.shared.resolve(OpenAIVoiceServiceProtocol.self)
        
        _startViewModel = StateObject(wrappedValue: StartViewModel(
            openAI: openAIService,
            voiceService: voiceService))
    }

    var body: some Scene {
        WindowGroup {
           StartView()
                .environmentObject(startViewModel)
        }
    }
}
