//
//  DataBaseTest.swift
//  AppTest
//
//  Created by DonHalab on 19.05.2024.
//

import CoreData
import XCTest
@testable import AppForMyDaughter


final class CoreDataTest: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager.shared
        coreDataManager.deleteAllMessages()
    }
    
    
    override func tearDown() {
        coreDataManager = nil
        super.tearDown()
    }
    
    
    func testAddCoreDataOneMessage() {
        var messages: [Messages] = []
        
        coreDataManager.addMessage(text: "Hello World", sender: "user")
        
        messages = coreDataManager.fetchMessages()
        
        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(messages.first?.text, "Hello World")
    }
    
    func testAddCoreDataThreeMessage() {
        var messages: [Messages] = []
        
        coreDataManager.addMessage(text: "Hello World", sender: "user")
        coreDataManager.addMessage(text: "Hey friend", sender: "assistent")
        coreDataManager.addMessage(text: "How are you?", sender: "user")
        messages = coreDataManager.fetchMessages()
        
        XCTAssertEqual(messages.count, 3)
        XCTAssertEqual(messages[1].sender, "assistent")
    }
    
    func testdeleteAll() {
        var messages: [Messages] = []
        
        coreDataManager.addMessage(text: "Hello World", sender: "user")
        coreDataManager.addMessage(text: "Hey friend", sender: "assistent")
        coreDataManager.addMessage(text: "How are you?", sender: "user")
        
        messages = coreDataManager.fetchMessages()
        
        coreDataManager.deleteAllMessages()
        
        messages = coreDataManager.fetchMessages()
        
        XCTAssertEqual(messages.count, 0)
    }

}

