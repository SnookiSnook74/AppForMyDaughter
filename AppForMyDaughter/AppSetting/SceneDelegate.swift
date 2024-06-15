//
//  SceneDelegate.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 19.05.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var diContainer: DIContainer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // Инициализируем и регистрируем зависимости в контейнере
        diContainer = DIContainer.shared
        diContainer?.registerServices()
        
        let startViewController = StartViewController()
        
        // Разрешаем зависимости
        if let container = diContainer {
            startViewController.openAI = container.resolve(OpenAIServiceProtocol.self)
            startViewController.voiceService = container.resolve(OpenAIVoiceServiceProtocol.self)
        }
        
        window.rootViewController = startViewController
        window.makeKeyAndVisible()
        self.window = window
    }
}

