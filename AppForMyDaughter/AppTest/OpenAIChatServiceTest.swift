//
//  OpenAIChatServiceTest.swift
//  AppTest
//
//  Created by DonHalab on 19.05.2024.
//

import Foundation
import XCTest
@testable import AppForMyDaughter


class OpenAIChatServiceTests: XCTestCase {
    
    var service: OpenAIChatService!
    
    override func setUp() {
        super.setUp()
        
        let historyList = [History(role: "system", content: "Hello!")]
        service = OpenAIChatService(model: .gpt3_5, apiKey: "testApiKey", systemMessage: "System message", historyList: historyList)
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        service.urlSession = URLSession(configuration: config)
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    func testSendMessage() async {
        let responseMessage = "This is a test response"
        let jsonResponse = """
        {
            "choices": [{
                "message": {
                    "role": "assistant",
                    "content": "\(responseMessage)"
                }
            }]
        }
        """
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = jsonResponse.data(using: .utf8)!
            return (response, data)
        }
        
        do {
            let result = try await service.sendMessage(text: "Test message")
            XCTAssertEqual(result, responseMessage)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
}
