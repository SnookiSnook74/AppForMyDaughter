//
//  Network Service.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 15.09.2024.
//

import Foundation

protocol NetworkServiceProtocol {
    /// Метод для отправки HTTP-запроса
    /// - Parameters:
    ///   - urlRequest: Запрос, который необходимо выполнить.
    /// - Throws: Ошибки сети или проблемы с парсингом данных.
    /// - Returns: Данные ответа в виде типа `Data`.
    func sendRequest(_ urlRequest: URLRequest) async throws -> Data
    
    /// Метод для отправки HTTP-запроса с декодированием ответа
    /// - Parameters:
    ///   - urlRequest: Запрос, который необходимо выполнить.
    ///   - decodingType: Тип, в который необходимо декодировать полученные данные.
    /// - Throws: Ошибки сети или проблемы с парсингом данных.
    /// - Returns: Декодированный объект типа `T`.
    func sendRequest<T: Decodable>(_ urlRequest: URLRequest, decodingType: T.Type) async throws -> T
    
    /// Метод для отправки HTTP-запроса с обработкой стримингового ответа
    /// - Parameter urlRequest: Запрос, который необходимо выполнить.
    /// - Throws: Ошибки сети или проблемы с получением данных.
    /// - Returns: Поток байтов (AsyncBytes) и ответ сервера (URLResponse).
    /// Этот метод используется для обработки потоковых ответов, например, в случае OpenAI, когда ответ поступает по частям.
    func sendRequestForStream(_ urlRequest: URLRequest) async throws -> (URLSession.AsyncBytes, URLResponse)
}

class NetworkService: NetworkServiceProtocol {
    
    static let shared = NetworkService()
    
    private let urlSession: URLSession
    
    private init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func sendRequest(_ urlRequest: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.invalidResponse(response)
            }
            
            return data
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    func sendRequest<T: Decodable>(_ urlRequest: URLRequest, decodingType: T.Type) async throws -> T {
        let data = try await sendRequest(urlRequest)
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func sendRequestForStream(_ urlRequest: URLRequest) async throws -> (URLSession.AsyncBytes, URLResponse) {
        let (bytes, response) = try await urlSession.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.invalidResponse(response)
        }
        
        return (bytes, response)
    }
    
}
extension NetworkService {
    enum NetworkError: LocalizedError {
        case invalidResponse(URLResponse?)
        case networkError(Error)
        case decodingError(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse(let response):
                return "Неверный ответ от сервера: \(response?.description ?? "unknown response")"
            case .networkError(let error):
                return "Ошибка сети: \(error.localizedDescription)"
            case .decodingError(let error):
                return "Ошибка декодирования данных: \(error.localizedDescription)"
            }
        }
    }
}
