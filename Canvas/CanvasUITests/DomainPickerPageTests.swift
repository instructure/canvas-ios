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
    
    

import Foundation
import XCTest
import SoAutomated

@available(iOS 9.0, *)
class DomainPickerPageTests: TestCase {

    // TODO: add reporting for TESTRAILS -- Priority: 1, Test-ID: 9779
    func testDomainPickerPage() {
        domainPickerPage.assertCanvasLogo()
        domainPickerPage.assertDomainField()
        domainPickerPage.openHelpMenu()
        domainPickerPage.assertHelpMenuOptions()
        domainPickerPage.closeHelpMenu()
        domainPickerPage.assertDomainField()
    }

    // TODO: add reporting for TESTRAILS -- Priority: 1, Test-ID: 235571
    func testDomainPickerPage_helpFindDomain() {
        domainPickerPage.gotoHelpFindDomain()
        findSchoolDomainPage.assertPage()
        findSchoolDomainPage.close()
        domainPickerPage.assertDomainField()
    }

    // TODO: define test case in TESTRAILS
    func testDomainPickerPage_helpReportProblem() {
        domainPickerPage.gotoHelpReportProblem()
        reportProblemPage.assertNavigationController()
        reportProblemPage.openImpactOptions()
        reportProblemPage.assertImpactNavigationController()
        reportProblemPage.assertImpactOptions()
        reportProblemPage.closeImpactOptions()
    }

    // TODO: define test case in TESTRAILS
    func testDomainPickerPage_helpRequestFeature() {
        domainPickerPage.gotoHelpRequestFeature()
        reportProblemPage.assertFeatureNavigationController()
        reportProblemPage.openImpactOptions()
        reportProblemPage.assertFeatureImpactNavigationController()
        reportProblemPage.assertImpactOptions()
        reportProblemPage.closeFeatureImpactOptions()
    }

    // TODO: add reporting for TESTRAILS -- Priority: 1, Test-ID: 235572
    // Fails due to midwifery.instructure.com matching "Utah" search text
//    func testDomainPickerPage_listDomains() {
//        domainPickerPage.enterSchool("Utah")
//        domainPickerPage.assertDomainList()
//        domainPickerPage.selectSchoolFromListByIndex()
//        loginPage.assertForm()
//        loginPage.close()
//        domainPickerPage.assertDomainField()
//    }

    // TODO: add reporting for TESTRAILS -- Priority: 1, Test-ID: 235573
    func testDomainPickerPage_routesToSchool() {
        domainPickerPage.loadSchool()
        loginPage.assertNavigationController(DomainPickerPage.defaultDomain)
    }

    // TODO: define test case in TESTRAILS
    func testDomainPickerPage_cantFindSchool() {
        domainPickerPage.enterSchool("jibberish")
        domainPickerPage.assertCantFindSchool()
        domainPickerPage.selectCantFindSchool()
        findSchoolDomainPage.assertPage()
    }

}
