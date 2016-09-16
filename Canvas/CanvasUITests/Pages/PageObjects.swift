import XCTest

@available(iOS 9.0, *)
extension XCTestCase {

    var domainPickerPage: DomainPickerPage {
        return DomainPickerPage(self)
    }

    var findSchoolDomainPage: FindSchoolDomainPage {
        return FindSchoolDomainPage(self)
    }

    var loginPage: LoginPage {
        return LoginPage(self)
    }

    var reportProblemPage: ReportProblemPage {
        return ReportProblemPage(self)
    }
}
