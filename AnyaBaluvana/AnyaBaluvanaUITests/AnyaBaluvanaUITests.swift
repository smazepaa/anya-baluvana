//
//  AnyaBaluvanaUITests.swift
//  AnyaBaluvanaUITests
//
//  Created by Yarrochka on 15.12.2024.
//

import XCTest

class AppUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    func testUserProfileEditing() {
        app.tabBars.buttons["User"].tap()
        
        let editButton = app.buttons["Edit"]
        XCTAssertTrue(editButton.exists)
        editButton.tap()
        
        let alert = app.alerts["Edit Phone Number"]
        XCTAssertTrue(alert.exists)
        
        let textField = alert.textFields.element
        XCTAssertTrue(textField.exists)
        
        textField.tap()
        textField.typeText("1234567890")
        
        alert.buttons["Save"].tap()
    }
    
   
}
