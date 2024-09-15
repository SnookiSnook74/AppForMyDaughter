//
//  ProxyService.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 26.05.2024.
//

import Foundation

/// Сервис для проксирования запроса
struct ProxyService {
    
    static func createProxySession() -> URLSession {
        
        /// Прокси-данные
        let proxyHost = "45.39.69.160"
        let proxyPort = 64750
        let proxyUsername = "6wwnShWc"
        let proxyPassword = "hJt8GNZQ"
        
        let config = URLSessionConfiguration.default
        let authString = "\(proxyUsername):\(proxyPassword)".data(using: .utf8)!.base64EncodedString()
        
        config.connectionProxyDictionary = [
            kCFNetworkProxiesHTTPEnable as String: true,
            kCFNetworkProxiesHTTPProxy as String: proxyHost,
            kCFNetworkProxiesHTTPPort as String: proxyPort,
            kCFNetworkProxiesProxyAutoConfigEnable as String: false,
            kCFStreamPropertyHTTPSProxyHost as String: proxyHost,
            kCFStreamPropertyHTTPSProxyPort as String: proxyPort,
            kCFProxyUsernameKey as String: proxyUsername,
            kCFProxyPasswordKey as String: proxyPassword
        ]
        
        config.httpAdditionalHeaders = [
            "Proxy-Authorization": "Basic \(authString)"
        ]
        
        return URLSession(configuration: config)
    }
}
