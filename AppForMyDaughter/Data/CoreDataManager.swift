//
//  CoreDataManager.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 19.05.2024.
//

import CoreData

class CoreDataManager {
    
   static let shared = CoreDataManager()
    
    private init() {}
    
    /// Инициализация и настройка NSPersistentContainer
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { storeDesctiption, error in
            if let error = error as NSError? {
                fatalError("Ошибка persistentContainer")
            }
            print(storeDesctiption.url)
        }
        return container
    }()
    
    /// Предоставление основного контекста управления объектами
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    /// Сохранение контекста при изменении
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Ошибка при сохранении контекста \(error.localizedDescription)")
            }
        }
    }
    
    /// Добавление сообщения в базу
    func addMessages(text: String, sender: String) {
        let context = self.context
        let message = Messages(context: context)
        
        message.text = text
        message.sender = sender
        
        saveContext()
    }
    
    /// Отчистка базы
    func deleteAllMesseges() {
        let context = self.context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Messages.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch {
            print("Ошибка при отчистке базы \(error.localizedDescription)")
        }
    }
    
    /// Получение всех объектов из базы данных
    func fetchMessages() -> [Messages] {
        let context = self.context
        let fetchRequest: NSFetchRequest<Messages> = Messages.fetchRequest()
        
        do {
            let messages = try context.fetch(fetchRequest)
            return messages
        } catch {
            print("Ошибка при получении объектов \(error.localizedDescription)")
            return []
        }
    }
}

