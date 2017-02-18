//
//  NewFileUploadTests.swift
//  FileKit
//
//  Created by Nathan Armstrong on 2/10/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

@testable import FileKit
import XCTest
import Nimble

class NewFileUploadTests: XCTestCase {
    func testMIMEType() {
        expect(MIMEType("MOV")) == "video/quicktime"
    }
}
