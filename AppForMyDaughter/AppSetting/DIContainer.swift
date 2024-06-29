//
//  DIContainer.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 25.05.2024.
//

import Foundation

/// Класс для регистрации всех зависимостей в приложении
class DIContainer {
    
    static let shared = DIContainer()
    private init() {}
    
    private var factories = [String: () -> Any]()
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = "\(type)"
        factories[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        guard let factory = factories[key] else { return nil }
        return factory() as? T
    }
}

extension DIContainer {
    
    func registerAllDependencies() {
        ServiceLayerAssembler().registerServices(in: self)
        DomainLayerAssebler().registerUseCases(in: self)
        PresenterLayerAssembler().registerViewModels(in: self)
    }
}

