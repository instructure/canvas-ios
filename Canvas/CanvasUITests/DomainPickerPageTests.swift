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
