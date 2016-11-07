//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import Foundation
import XCTest
import SoAutomated

@available(iOS 9.0, *)
class LoginPageTests: TestCase {

    // TODO: add reporting for TESTRAILS -- Priority: 1, Test-ID: 14040
    func testLoginPage_correctURL() {
        domainPickerPage.loadSchool()
        loginPage.assertPage()
    }

    // TODO: add reporting for TESTRAILS -- Priority: 2, Test-ID: 419579
    func testLoginPage_appendInstructureToURL() {
        domainPickerPage.loadSchool(DomainPickerPage.defaultDomainShort)
        loginPage.assertPage()
    }

    // TODO: add reporting for TESTRAILS -- Priority: 1, Test-ID: 251028
    func testLoginPage_cancel() {
        domainPickerPage.loadSchool()
        loginPage.close()
        domainPickerPage.assertDomainField()
    }

    // TODO: add reporting for TESTRAILS -- Priority: 1, Test-ID: 235575
    func testLoginPage_resetPassword() {
        domainPickerPage.loadSchool()
        loginPage.openPasswordReset()
        loginPage.assertNavigationController()
        loginPage.assertResetForm()
        loginPage.closePasswordReset()
        loginPage.assertForm()
    }

    // TODO: add reporting for TESTRAILS
    func testLogin_rejectsInvalidCredentials() {
        domainPickerPage.loadSchool()
        loginPage.login("user", "password")
        loginPage.assertIncorrectUserOrPasswordError()
    }

    func testLoginPage_displaysNavigationBarTitle() {
        domainPickerPage.loadSchool()
        loginPage.assertNavigationBarTitle()
    }
}
