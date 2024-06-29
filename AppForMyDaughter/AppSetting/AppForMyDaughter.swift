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
        DIContainer.shared.registerAllDependencies()
        
        guard let startViewModel = DIContainer.shared.resolve(StartViewModel.self) else {
            fatalError("StartViewModel не зарегистрирован в DIContainer")
        }
        
        _startViewModel = StateObject(wrappedValue: startViewModel)

    }

    var body: some Scene {
        WindowGroup {
           StartView()
                .environmentObject(startViewModel)
        }
    }
}
