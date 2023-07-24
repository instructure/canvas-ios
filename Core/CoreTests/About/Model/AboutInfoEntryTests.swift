//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

@testable import Core
import XCTest

class AboutInfoEntryTests: XCTestCase {

    func testIdentifiable() {
        let testee = AboutInfoEntry(title: "testTitle", label: "testLabel")
        XCTAssertEqual(testee.id, "testTitle")
    }

    // MARK: - A11y

    func testA11yLabel() {
        let testee = AboutInfoEntry(title: "testTitle", label: "testLabel")
        XCTAssertEqual(testee.a11yLabel, "testTitle,testLabel")
    }

    func testA11yWithEmptyLabel() {
        let testee = AboutInfoEntry(title: "testTitle", label: AboutInfoEntry.UnknownLabel)
        XCTAssertEqual(testee.a11yLabel, "testTitle,Unknown")
    }

    // MARK: - App

    func testAppEntryWithoutApp() {
        let testee = AboutInfoEntry.app(nil)
        XCTAssertEqual(testee.title, "App")
        XCTAssertEqual(testee.label, "-")
    }

    func testAppEntryWithParentApp() {
        let testee = AboutInfoEntry.app(.parent)
        XCTAssertEqual(testee.label, "Canvas Parent")
    }

    func testAppEntryWithStudentApp() {
        let testee = AboutInfoEntry.app(.student)
        XCTAssertEqual(testee.label, "Canvas Student")
    }

    func testAppEntryWithTeacherApp() {
        let testee = AboutInfoEntry.app(.teacher)
        XCTAssertEqual(testee.label, "Canvas Teacher")
    }

    // MARK: - Domain

    func testDomainEntryWithoutSession() {
        let testee = AboutInfoEntry.domain(nil)
        XCTAssertEqual(testee.title, "Domain")
        XCTAssertEqual(testee.label, "-")
    }

    func testDomainEntryWithSession() {
        let session = LoginSession(baseURL: URL(string: "https://instructure.com/testPath")!,
                                   userID: "1",
                                   userName: "testName")
        let testee = AboutInfoEntry.domain(session)
        XCTAssertEqual(testee.title, "Domain")
        XCTAssertEqual(testee.label, "https://instructure.com")
    }

    // MARK: - Login ID

    func testLoginIDEntryWithEmptySession() {
        let testee = AboutInfoEntry.loginID(nil)
        XCTAssertEqual(testee.title, "Login ID")
        XCTAssertEqual(testee.label, "-")
    }

    func testLoginIDEntry() {
        let testee = AboutInfoEntry.loginID(.make(userID: "123"))
        XCTAssertEqual(testee.title, "Login ID")
        XCTAssertEqual(testee.label, "123")
    }

    // MARK: - Email

    func testEmailEntryWithEmptySession() {
        let testee = AboutInfoEntry.email(nil)
        XCTAssertEqual(testee.title, "Email")
        XCTAssertEqual(testee.label, "-")
    }

    func testEmailEntryWithEmptyEmail() {
        let testee = AboutInfoEntry.email(.make(userEmail: nil))
        XCTAssertEqual(testee.title, "Email")
        XCTAssertEqual(testee.label, "-")
    }

    func testEmailEntryWithValidEmail() {
        let testee = AboutInfoEntry.email(.make(userEmail: "testEmail"))
        XCTAssertEqual(testee.title, "Email")
        XCTAssertEqual(testee.label, "testEmail")
    }

    // MARK: - Version

    func testVersion() {
        let testee = AboutInfoEntry.version(MockBundle(bundleVersion: .string("1.0.1")))
        XCTAssertEqual(testee.title, "Version")
        XCTAssertEqual(testee.label, "1.0.1")
    }

    func testNonStringVersion() {
        let testee = AboutInfoEntry.version(MockBundle(bundleVersion: .int(101)))
        XCTAssertEqual(testee.title, "Version")
        XCTAssertEqual(testee.label, "-")
    }
}

private class MockBundle: Bundle {
    enum BundleVersion {
        case string(String)
        case int(Int)
    }
    private let bundleVersion: BundleVersion

    init(bundleVersion: BundleVersion) {
        self.bundleVersion = bundleVersion
        super.init()
    }

    override func object(forInfoDictionaryKey key: String) -> Any? {
        guard key == "CFBundleShortVersionString" else {
            return nil
        }

        switch bundleVersion {
        case .string(let version): return version
        case .int(let version): return version
        }
    }
}
