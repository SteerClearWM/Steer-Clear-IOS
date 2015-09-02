//
//  Steer_ClearTests.swift
//  Steer ClearTests
//
//  Created by Ulises Giacoman on 5/15/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import XCTest
import Foundation

class Steer_ClearTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSuccessfulRegisterandConflict() {
        var networkController = Network()
        var responso = 0
        let username = "ugiacoman"
        let password = ""
        let phone =  "7036786244"
        
        
        // Successful Register Test
        print("testSuccessfulRegisterandConflict info: username: \(username), password: \(password), phone: \(phone) \n")
        networkController.register(username as String, password: password as String, phone: phone)
        while (networkController.responseFound != true){
            usleep(3000)
        }
        networkController.responseFound = false
        responso = networkController.responseStatus
        XCTAssertEqual(responso, 200)
        print("Unique Register Successfull \n")
        
        // Conflict Register Test
        networkController.register(username as String, password: password as String, phone: phone)
        while (networkController.responseFound != true){
            usleep(3000)
        }
        networkController.responseFound = false
        responso = networkController.responseStatus
        XCTAssertEqual(responso, 409)
        print("Conflict Submission Successfull \n")
    }
    
//    func testLogout() {
//        var networkController = Network()
//        var responso = 0
//        let email = randomStringWithLength(5)
//        let password = randomStringWithLength(5)
//        let phone =  "703" + (randomIntWithLength(7) as String)
//        networkController.register(email as String, password: password as String, phone: phone)
//        print("testLogout info: email: \(email), password: \(password), phone: \(invalidPhone) \n")
//        XCTAssertEqual(responso, 200)
//    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    func randomIntWithLength (len : Int) -> NSString {
        
        let letters : NSString = "0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
}