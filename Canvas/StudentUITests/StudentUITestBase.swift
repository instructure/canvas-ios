//
//  StudentUITest.swift
//  StudentUITests
//
//  Created by Layne Moseley on 4/12/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

import Foundation
import XCTest
import SoGrey
import EarlGrey
import CanvasCore
import SoSeedySwift
@testable import CanvasKeymaster

class StudentUITestBase: CanvasUITest {
    override func setUp() {
        super.setUp()
        CanvasKeymaster.the().resetKeymasterForTesting()
        NativeLoginManager.shared().injectLoginInformation(nil)
        GREYTestHelper.enableFastAnimation()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
