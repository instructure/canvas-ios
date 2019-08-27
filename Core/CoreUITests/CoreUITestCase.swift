//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import XCTest
import TestsFoundation
@testable import Core

open class CoreUITestCase: XCTestCase {
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let pasteboardType = "com.instructure.ui-test-helper"
    open var homeScreen: Element { return TabBar.dashboardTab }

    open var user: UITestUser? {
        if Bundle.main.isStudentUITestsRunner {
            return .readStudent1
        } else if Bundle.main.isTeacherUITestsRunner {
            return .readTeacher1
        } else {
            return nil
        }
    }

    // The class in this variable will not have tests run for it, only for subclasses
    open var abstractTestClass: CoreUITestCase.Type { return CoreUITestCase.self }

    open override func perform(_ run: XCTestRun) {
        if type(of: self) != abstractTestClass {
            super.perform(run)
        }
    }

    private static var firstRun = true

    open override func setUp() {
        super.setUp()
        continueAfterFailure = false
        if CoreUITestCase.firstRun || app.state != .runningForeground {
            CoreUITestCase.firstRun = false
            launch()
            if currentSession() != nil {
                homeScreen.waitToExist()
            }
        }
        reset()
        if let user = user {
            logInUser(user)
            homeScreen.waitToExist()
        }
    }

    open override func tearDown() {
        super.tearDown()
        send(.tearDown)
    }

    open func launch(_ block: ((XCUIApplication) -> Void)? = nil) {
        let app = XCUIApplication()
        app.launchEnvironment["IS_UI_TEST"] = "TRUE"
        block?(app)
        app.launch()
        // Wait for RN to finish loading
        app.find(labelContaining: "Loading").waitToVanish(120)
    }

    func send<T: Encodable>(_ type: UITestHelpers.HelperType, _ data: T) {
        send(type, data: try! encoder.encode(data))
    }

    func send(_ type: UITestHelpers.HelperType, data: Data? = nil) {
        let data = try! encoder.encode(UITestHelpers.Helper(type: type, data: data))
        UIPasteboard.general.items.removeAll()
        UIPasteboard.general.setData(data, forPasteboardType: pasteboardType)
        app.find(id: "ui-test-helper").tap()
    }

    open func reset(file: StaticString = #file, line: UInt = #line) {
        send(.reset)
        LoginStart.findSchoolButton.waitToExist(file: file, line: line)
    }

    open func logIn(domain: String = "canvas.instructure.com", token: String = "t", file: StaticString = #file, line: UInt = #line) {
        let baseURL = URL(string: "https://\(domain)")!
        logInEntry(LoginSession(
            accessToken: token,
            baseURL: baseURL,
            expiresAt: nil,
            locale: "en",
            refreshToken: nil,
            userID: "",
            userName: ""
        ), file: file, line: line)
    }

    open func logInEntry(_ session: LoginSession, file: StaticString = #file, line: UInt = #line) {
        send(.login, session)
        homeScreen.waitToExist(file: file, line: line)
    }

    open func logInUser(_ user: UITestUser) {
        if let entry = user.session {
            return logInEntry(entry)
        }

        // Assumes we are on the login start screen
        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.typeText("\(user.host)\r")

        LoginWeb.emailField.waitToExist(60)
        LoginWeb.emailField.typeText(user.username)
        LoginWeb.passwordField.typeText(user.password)
        LoginWeb.logInButton.tap()

        homeScreen.waitToExist()
        user.session = currentSession()
    }

    open func currentSession() -> LoginSession? {
        send(.currentSession)
        guard
            let data = UIPasteboard.general.data(forPasteboardType: pasteboardType),
            let helper = try? decoder.decode(UITestHelpers.Helper.self, from: data),
            helper.type == .currentSession, let entryData = helper.data
        else { return nil }
        return try? decoder.decode(LoginSession.self, from: entryData)
    }

    open func show(_ route: String) {
        send(.show, [ route ])
    }

    open func mockData<R: APIRequestable>(
        _ requestable: R,
        value: R.Response? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false
    ) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = value.flatMap { try! encoder.encode($0) }
        return mockEncodedData(requestable, data: data, response: response, error: error, noCallback: noCallback)
    }

    open func mockEncodedData<R: APIRequestable>(
        _ requestable: R,
        data: Data? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false
    ) {
        let api = URLSessionAPI()
        let request = try! requestable.urlRequest(relativeTo: api.baseURL, accessToken: api.accessToken, actAsUserID: api.actAsUserID)
        return mockDataRequest(request, data: data, response: response, error: error, noCallback: noCallback)
    }

    open func mockEncodableRequest<D: Codable>(
        _ path: String,
        value: D? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false
    ) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = value.flatMap { try! encoder.encode($0) }
        let api = URLSessionAPI()
        let url = URL(string: path, relativeTo: api.baseURL.appendingPathComponent("api/v1/"))!
        mockDataRequest(URLRequest(url: url), data: data, response: response, error: error, noCallback: noCallback)
    }

    open func mockDataRequest(
        _ request: URLRequest,
        data: Data? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false
    ) {
        send(.mockData, MockDataMessage(
            data: data,
            error: error,
            request: request,
            response: response.flatMap { MockResponse(http: $0) },
            noCallback: noCallback
        ))
    }

    open func mockDownload(
        _ url: URL,
        data: URL? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil
    ) {
        send(.mockDownload, MockDownloadMessage(
            data: data.flatMap { try! Data(contentsOf: $0) },
            error: error,
            response: response.flatMap { MockResponse(http: $0) },
            url: url
        ))
    }

    open func mockBaseRequests() {
        mockData(GetUserRequest(userID: "self"), value: APIUser.make())
        mockDataRequest(URLRequest(url: URL(string: "https://canvas.instructure.com/api/v1/users/self/profile?per_page=50")!), data: """
        {"id":1,"name":"Bob","short_name":"Bob","sortable_name":"Bob","locale":"en"}
        """.data(using: .utf8)) // CKIClient.fetchCurrentUser
        mockDataRequest(URLRequest(url: URL(string: "https://canvas.instructure.com/api/v1/users/self/profile")!), data: """
        {"id":1,"name":"Bob","short_name":"Bob","sortable_name":"Bob","locale":"en"}
        """.data(using: .utf8))
        mockData(GetWebSessionRequest(to: URL(string: "https://canvas.instructure.com/users/self"))) // cookie keepalive
        mockData(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [:]))
        mockData(GetBrandVariablesRequest(), value: APIBrandVariables.make())
        mockData(GetUserSettingsRequest(userID: "self"), value: APIUserSettings.make())
        mockData(GetAccountNotificationsRequest(), value: [])
        let enrollment = APIEnrollment.make(
            type: Bundle.main.isTeacherUITestsRunner ? "TeacherEnrollment" : "StudentEnrollment",
            role: Bundle.main.isTeacherUITestsRunner ? "TeacherEnrollment" : "StudentEnrollment"
        )
        var state: [GetCoursesRequest.State] = [.available, .completed]
        if Bundle.main.isTeacherApp {
            state.append(.unpublished)
        }
        mockData(GetCoursesRequest(state: state), value: [ .make(id: "1", enrollments: [ enrollment ]) ])
        mockData(GetEnabledFeatureFlagsRequest(context: ContextModel(.course, id: "1")), value: [ "rce_enhancements" ])
        mockEncodableRequest("courses/1/external_tools?per_page=99&include_parents=true", value: [String]())
        mockEncodableRequest("users/self/custom_data/favorites/groups?ns=com.canvas.canvas-app", value: [String: String]())
        mockEncodableRequest("users/self/enrollments?include[]=avatar_url", value: [enrollment])
        mockEncodableRequest("users/self/groups", value: [String]())
        mockEncodableRequest("users/self/todo", value: [String]())
        mockEncodableRequest("conversations/unread_count", value: ["unread_count": 0])
        mockEncodableRequest("dashboard/dashboard_cards", value: [String]())
    }

    open func pullToRefresh() {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9)))
    }

    open func allowAccessToPhotos(block: () -> Void) {
        let alertHandler = addUIInterruptionMonitor(withDescription: "Photos Access Alert") { (alert) -> Bool in
            _ = alert.buttons["OK"].waitForExistence(timeout: 3)
            alert.buttons["OK"].tap()
            return true
        }
        block()
        app.swipeUp()
        removeUIInterruptionMonitor(alertHandler)
    }

    open func allowAccessToMicrophone(block: () -> Void) {
        let alertHandler = addUIInterruptionMonitor(withDescription: "Permission Alert") { (alert) -> Bool in
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            return false
        }
        block()
        app.swipeUp()
        removeUIInterruptionMonitor(alertHandler)
    }
}
