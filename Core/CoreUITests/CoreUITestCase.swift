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

    open func reset() {
        send(.reset)
        LoginStart.findSchoolButton.waitToExist()
    }

    open func logIn(domain: String, token: String) {
        let baseURL = URL(string: "https://\(domain)")!
        send(.login, LoginSession(
            accessToken: token,
            baseURL: baseURL,
            expiresAt: nil,
            locale: "en",
            refreshToken: nil,
            userID: "",
            userName: ""
        ))
    }

    open func logInEntry(_ session: LoginSession) {
        send(.login, session)
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

        app.find(label: "Courses").waitToExist()
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
        mockData(GetWebSessionRequest(to: URL(string: "https://canvas.instructure.com/users/self?display=borderless"))) // cookie keepalive
        mockData(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [:]))
        mockData(GetBrandVariablesRequest(), value: APIBrandVariables.make())
        mockData(GetUserSettingsRequest(userID: "self"), value: APIUserSettings.make())
        mockEncodableRequest("users/self/todo", value: [String]())
        mockEncodableRequest("conversations/unread_count", value: ["unread_count": 0])
        mockEncodableRequest("dashboard/dashboard_cards", value: [String]())
    }
}
