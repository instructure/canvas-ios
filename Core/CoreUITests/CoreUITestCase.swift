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
    open var homeScreen: Element { return TabBar.dashboardTab }

    open var dataMocks = [MockDataMessage]()
    open var downloadMocks = [MockDownloadMessage]()

    open var user: UITestUser? {
        if Bundle.main.isStudentApp {
            return .readStudent1
        } else if Bundle.main.isTeacherApp {
            return .readTeacher1
        } else {
            return nil
        }
    }

    // The class in this variable will not have tests run for it, only for subclasses
    open var abstractTestClass: CoreUITestCase.Type { return CoreUITestCase.self }

    open override func perform(_ run: XCTestRun) {
        guard type(of: self) != abstractTestClass else { return }

        CoreUITestCase.currentTestCase = self
        if ProcessInfo.processInfo.environment["LIST_TESTS_ONLY"] == "YES" {
            print("UI_TEST: \(Bundle(for: type(of: self)).bundleURL.deletingPathExtension().lastPathComponent) \(name)")
        } else {
            super.perform(run)
        }
        CoreUITestCase.currentTestCase = nil
    }

    open class CoreUITestRun: XCTestCaseRun {
        override open func recordFailure(withDescription description: String, inFile filePath: String?, atLine lineNumber: Int, expected: Bool) {
            CoreUITestCase.needsLaunch = true
            super.recordFailure(withDescription: description, inFile: filePath, atLine: lineNumber, expected: expected)
        }
    }

    override open var testRunClass: AnyClass? { return CoreUITestRun.self }

    private let isRetry = ProcessInfo.processInfo.environment["CANVAS_TEST_IS_RETRY"] == "YES"

    private static var needsLaunch = true
    open override func setUp() {
        super.setUp()
        LoginSession.useTestKeychain()
        continueAfterFailure = false
        if CoreUITestCase.needsLaunch || app.state != .runningForeground || isRetry {
            CoreUITestCase.needsLaunch = false
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
        // re-install the existing mocks
        for message in dataMocks {
            send(.mockData(message))
        }
        for message in downloadMocks {
            send(.mockDownload(message))
        }
    }

    open override func tearDown() {
        send(.tearDown)
        LoginSession.clearAll()
        super.tearDown()
    }

    public var failTestOnMissingMock = true
    static var currentTestCase: CoreUITestCase?

    class ServerDelegate: IPCDriverServerDelegate {
        public func handler(_ message: IPCDriverServerMessage) -> Data? {
            switch message {
            case .mockNotFound(let reason):
                if currentTestCase?.failTestOnMissingMock == true {
                    XCTFail(reason)
                } else {
                    print("missing mock (allowed): \(reason)")
                }
            }
            // unreachable
            return nil
        }
    }
    static let delegate = ServerDelegate()

    let ipcAppClient: IPCClient = IPCClient(serverPortName: IPCAppServer.portName(id: "\(ProcessInfo.processInfo.processIdentifier)"))
    static let ipcDriverServer: IPCDriverServer = IPCDriverServer(machPortName: IPCDriverServer.portName(id: "\(ProcessInfo.processInfo.processIdentifier)"), delegate: delegate)

    open func launch(_ block: ((XCUIApplication) -> Void)? = nil) {
        let app = XCUIApplication()
        app.launchEnvironment["IS_UI_TEST"] = "TRUE"
        app.launchEnvironment["APP_IPC_PORT_NAME"] = ipcAppClient.serverPortName
        app.launchEnvironment["DRIVER_IPC_PORT_NAME"] = CoreUITestCase.ipcDriverServer.machPortName
        block?(app)
        app.launch()
        // Wait for RN to finish loading
        app.find(labelContaining: "Loading").waitToVanish(120)
    }

    func send(_ helper: UITestHelpers.Helper, ignoreErrors: Bool = false) {
        do {
            if let response = try ipcAppClient.requestRemote(helper),
                !response.isEmpty {
                throw IPCError(message: "Unexpected IPC response")
            }
        } catch let error {
            if !ignoreErrors {
                XCTFail("IPC failed: \(error)")
            }
        }
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
        send(.login(session))
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
        guard let data = try? ipcAppClient.requestRemote(UITestHelpers.Helper.currentSession) else {
            fatalError("Bad IPC response (no data returned)")
        }
        if data.isEmpty || data == "null".data(using: .utf8) {
            return nil
        } else {
            return (try? JSONDecoder().decode(LoginSession?.self, from: data))!
        }
    }

    open func show(_ route: String) {
        if currentSession() == nil {
            logIn()
        }
        send(.show(route))
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
            _ = alert.buttons["OK"].waitForExistence(timeout: 3)
            alert.buttons["OK"].tap()
            return true
        }
        block()
        app.swipeUp()
        removeUIInterruptionMonitor(alertHandler)
    }

    open func setAnimationsEnabled(_ enabled: Bool) {
        send(.setAnimationsEnabled(enabled))
    }

    open func mockNow(_ date: Date) {
        send(.mockNow(date))
    }

    // MARK: mock (convenience)

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
        let request = try! requestable.urlRequest(relativeTo: api.baseURL, accessToken: api.loginSession?.accessToken, actAsUserID: api.loginSession?.actAsUserID)
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

    @discardableResult
    open func mock(course: APICourse) -> APICourse {
        mockData(GetCourseRequest(courseID: course.id), value: course)
        mockData(GetEnabledFeatureFlagsRequest(context: ContextModel(.course, id: course.id)), value: ["rce_enhancements"])
        mockEncodableRequest("courses/\(course.id)/external_tools?per_page=99&include_parents=true", value: [String]())
        return course
    }

    @discardableResult
    open func mock(assignment: APIAssignment) -> APIAssignment {
        mockData(GetAssignmentRequest(courseID: assignment.course_id.value, assignmentID: assignment.id.value, include: [ .submission ]), value: assignment)
        mockData(GetAssignmentRequest(courseID: assignment.course_id.value, assignmentID: assignment.id.value, include: []), value: assignment)
        for submission in assignment.submission?.values ?? [] {
            mockData(GetSubmissionRequest(
                context: ContextModel(.course, id: assignment.course_id.value),
                assignmentID: assignment.id.value, userID: "1"),
                value: submission)
        }

        return assignment
    }

    open func mockBaseRequests() {
        mockData(GetUserRequest(userID: "self"), value: APIUser.make())
        mockDataRequest(URLRequest(url: URL(string: "https://canvas.instructure.com/api/v1/users/self/profile?per_page=50")!),
                        data: #"{"id":1,"name":"Bob","short_name":"Bob","sortable_name":"Bob","locale":"en"}"#.data(using: .utf8)) // CKIClient.fetchCurrentUser
        mockDataRequest(URLRequest(url: URL(string: "https://canvas.instructure.com/api/v1/users/self/profile")!),
                        data: #"{"id":1,"name":"Bob","short_name":"Bob","sortable_name":"Bob","locale":"en"}"#.data(using: .utf8))
        mockData(GetWebSessionRequest(to: URL(string: "https://canvas.instructure.com/users/self"))) // cookie keepalive
        mockData(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [:]))
        mockData(GetBrandVariablesRequest(), value: APIBrandVariables.make())
        mockData(GetUserSettingsRequest(userID: "self"), value: APIUserSettings.make())
        mockData(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: .make())
        mockData(GetAccountNotificationsRequest(), value: [])
        let enrollment = APIEnrollment.make(
            type: Bundle.main.isTeacherUITestsRunner ? "TeacherEnrollment" : "StudentEnrollment",
            role: Bundle.main.isTeacherUITestsRunner ? "TeacherEnrollment" : "StudentEnrollment"
        )
        var state: [GetCoursesRequest.State] = [.available, .completed]
        if Bundle.main.isTeacherApp {
            state.append(.unpublished)
        }
        let course = mock(course: .make(enrollments: [ enrollment ]))
        mockData(GetCoursesRequest(enrollmentState: nil, state: state), value: [ course ])
        mockEncodableRequest("users/self/custom_data/favorites/groups?ns=com.canvas.canvas-app", value: [String: String]())
        mockEncodableRequest("users/self/enrollments?include[]=avatar_url", value: [enrollment])
        mockEncodableRequest("users/self/groups", value: [String]())
        mockEncodableRequest("users/self/todo_item_count", value: ["needs_grading_count": 0])
        mockEncodableRequest("users/self/todo", value: [String]())
        mockEncodableRequest("conversations/unread_count", value: ["unread_count": 0])
        mockEncodableRequest("dashboard/dashboard_cards", value: [String]())

        let pixel = UIImage(data: Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=")!)!
        mockDataRequest(URLRequest(url: URL(string: "https://instructure-uploads.s3.amazonaws.com/account_70000000000010/attachments/64473710/canvas_logomark_only2x.png")!),
                        data: pixel.pngData()!)
    }

    // MARK: mock (primitive)

    open func mockDataRequest(
        _ request: URLRequest,
        data: Data? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false
    ) {
        let message = MockDataMessage(
            data: data,
            error: error,
            request: request,
            response: response.flatMap { MockResponse(http: $0) },
            noCallback: noCallback
        )
        dataMocks.append(message)
        send(.mockData(message))
    }

    open func mockDownload(
        _ url: URL,
        data: URL? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil
    ) {
        let message = MockDownloadMessage(
            data: data.flatMap { try! Data(contentsOf: $0) },
            error: error,
            response: response.flatMap { MockResponse(http: $0) },
            url: url
        )
        downloadMocks.append(message)
        send(.mockDownload(message))
    }
}
