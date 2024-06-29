# AppForMyDaughter

AppForMyDaughter — это приложение для создания увлекательных интерактивных историй для детей в стиле Dungeons & Dragons, с возможностью голосового воспроизведения с помощью сервиса OpenAI.

## Оглавление

- [Установка](#установка)
- [Использование](#использование)
- [Архитектура](#архитектура)
- [Зависимости](#зависимости)

## Установка

Для начала, клонируйте репозиторий:

```bash
git clone https://github.com/ваш-логин/AppForMyDaughter.git

Не забудьте установить API ключи для сервиса OpenAI. Добавьте их в Info.plist:

<key>OPENAI_API_KEY</key>
<string>ваш-api-ключ</string>
```

## Использование

Просто запустите проект в Xcode на вашем симуляторе или устройстве. 
Приложение начнет воспроизводить интерактивные истории, используя OpenAI для генерации контента и синтеза речи.

## Архитектура

Проект построен с использованием многослойной архитектуры для улучшения модульности и тестируемости. Основные слои:

Service Layer: Содержит реализацию логики взаимодействия с внешними сервисами.
Data Layer: Содержит логику для работы с данными
Domain Layer: Инкапсулирует бизнес-логику приложения.
Presenter Layer: Содержит логику, связанную с представлением данных

## DIContainer

Для управления зависимостями используется DIContainer. 
Зависимости регистрируются и разрешаются с помощью этого контейнера, что позволяет легко управлять и тестировать компоненты.

Пример регистрации зависимостей:
```bash
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
    
    func registerAllDependencies() {
        ServiceLayerDependencies().registerServices(in: self)
        UseCaseLayerDependencies().registerUseCases(in: self)
        ViewModelLayerDependencies().registerViewModels(in: self)
    }
}
```
