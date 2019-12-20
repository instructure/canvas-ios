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
@testable import Core

open class CoreUITestCase: XCTestCase {
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    open var homeScreen: Element { TabBar.dashboardTab }

    open var httpMocks = [URL: () -> MockHTTPResponse]()

    private var usingMocksOnly = false
    open func useMocksOnly() {
        if usingMocksOnly { return }
        usingMocksOnly = true
        send(.useMocksOnly)
    }

    open var user: UITestUser? {
        if Bundle.main.isStudentApp {
            return .readStudent1
        } else if Bundle.main.isTeacherApp {
            return .readTeacher1
        } else {
            return nil
        }
    }

    open var experimentalFeatures: [ExperimentalFeature] { [] }

    // The class in this variable will not have tests run for it, only for subclasses
    open var abstractTestClass: CoreUITestCase.Type { CoreUITestCase.self }

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

    override open var testRunClass: AnyClass? { CoreUITestRun.self }

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
        send(.enableExperimentalFeatures(experimentalFeatures))
        if let user = user {
            logInUser(user)
            homeScreen.waitToExist()
        }
        // re-install the existing mocks
        if (usingMocksOnly) {
            send(.useMocksOnly)
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
            case .urlRequest(let request):
                guard let url = request.url,
                    let testCase = currentTestCase else {
                    return nil
                }
                guard let mock = testCase.httpMocks[url.withCanonicalQueryParams!] else {
                    print("installed mocks:")
                    var mockKeys = testCase.httpMocks.map { $0.key.absoluteString }
                    let targetKey = url.absoluteString
                    var similarity = [String: Int]()
                    for key in mockKeys {
                        similarity[key] = targetKey.commonPrefix(with: key).count
                    }
                    mockKeys.sort { (similarity[$0]!, $0) < (similarity[$1]!, $1) }
                    for key in mockKeys {
                        print("  \(key)")
                    }
                    print("mock not found for url:\n  \(url.absoluteString)")
                    if testCase.failTestOnMissingMock {
                        XCTFail("missing mock: \(url.absoluteString)")
                        return nil
                    } else {
                        return try? JSONEncoder().encode(MockHTTPResponse(errorMessage: "unmocked"))
                    }
                }
                return try? JSONEncoder().encode(mock())
            }
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

    open func send(_ helper: UITestHelpers.Helper, ignoreErrors: Bool = false) {
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
        let window = app.find(type: .window)
        window.relativeCoordinate(x: 0.5, y: 0.5)
            .press(forDuration: 0.05, thenDragTo: window.relativeCoordinate(x: 0.5, y: 1.0))
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
        Clock.mockNow(date)
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
        return mockRequest(request, data: data, response: response, error: error, noCallback: noCallback)
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
        mockURL(url, data: data, response: response, error: error, noCallback: noCallback)
    }

    open func mockGraphQL(_ json: Any) {
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        let api = URLSessionAPI()
        let url = URL(string: "/api/graphql", relativeTo: api.baseURL)!
        mockURL(url, data: data, response: nil, error: nil, noCallback: false)
    }

    @discardableResult
    open func mock(course: APICourse) -> APICourse {
        mockData(GetCourseRequest(courseID: course.id), value: course)
        mockData(GetCourseRequest(courseID: course.id, include: [
            .courseImage,
            .currentGradingPeriodScores,
            .favorites,
            .permissions,
            .sections,
            .syllabusBody,
            .term,
            .totalScores,
        ]), value: course)
        mockData(GetEnabledFeatureFlagsRequest(context: ContextModel(.course, id: course.id)), value: ["rce_enhancements"])
        mockEncodableRequest("courses/\(course.id)/external_tools?include_parents=true&per_page=99", value: [String]())
        mockEncodableRequest("courses/\(course.id)/external_tools?include_parents=true", value: [String]())
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

    @discardableResult
    open func mock(courses: [APICourse]) -> [APICourse] {
        courses.forEach { mock(course: $0) }
        var state: [GetCoursesRequest.State] = [.available, .completed]
        if Bundle.main.isTeacherApp {
            state.append(.unpublished)
        }
        mockData(GetCoursesRequest(enrollmentState: nil, state: state), value: courses)
        return courses
    }

    open lazy var baseEnrollment = APIEnrollment.make(
        type: Bundle.main.isTeacherUITestsRunner ? "TeacherEnrollment" : "StudentEnrollment",
        role: Bundle.main.isTeacherUITestsRunner ? "TeacherEnrollment" : "StudentEnrollment"
    )
    open lazy var baseCourse = mock(course: .make(enrollments: [ baseEnrollment ]))

    open func mockBaseRequests() {
        mockData(GetUserRequest(userID: "self"), value: APIUser.make())
        mockEncodableRequest("users/self/profile?per_page=50", value: APIUser.make()) // CKIClient.fetchCurrentUser
        mockEncodableRequest("users/self/profile", value: APIUser.make())
        mockData(GetWebSessionRequest(to: URL(string: "https://canvas.instructure.com/users/self"))) // cookie keepalive
        mockData(GetCustomColorsRequest(), value: APICustomColors(custom_colors: ["course_1": "#5F4DCE"]))
        mockData(GetBrandVariablesRequest(), value: APIBrandVariables.make())
        mockData(GetUserSettingsRequest(userID: "self"), value: APIUserSettings.make())
        mockData(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: .make())
        mockData(GetAccountNotificationsRequest(), value: [])
        mock(courses: [ baseCourse ])
        mockData(GetDashboardCardsRequest(), value: [APIDashboardCard.make()])
        mockEncodableRequest("users/self/custom_data/favorites/groups?ns=com.canvas.canvas-app", value: [String: String]())
        mockEncodableRequest("users/self/enrollments?include[]=avatar_url", value: [baseEnrollment])
        mockEncodableRequest("users/self/groups", value: [String]())
        mockEncodableRequest("users/self/todo_item_count", value: ["needs_grading_count": 0])
        mockEncodableRequest("users/self/todo", value: [String]())
        mockEncodableRequest("conversations/unread_count", value: ["unread_count": 0])
    }

    open func mockURL(
        _ url: URL,
        data: Data? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false
    ) {
        mockRequest(URLRequest(url: url), data: data, response: response, error: error, noCallback: noCallback)
    }

    open func mockURL(
        _ url: URL,
        dynamicData: @escaping () -> Data
    ) {
        mockResponse(URLRequest(url: url)) {
            let data = dynamicData()
            let http = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [
                HttpHeader.contentType: "application/json",
            ])
            return MockHTTPResponse(data: data, http: http)
        }
    }

    open func mockRequest(
        _ request: URLRequest,
        data: Data? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false
    ) {
        var http = response
        if response == nil, data != nil {
            http = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [
                HttpHeader.contentType: "application/json",
            ])
        }

        let mockHTTPResponse = MockHTTPResponse(
            data: data,
            http: http,
            errorMessage: error,
            noCallback: noCallback
        )
        mockResponse(request, response: { mockHTTPResponse })
    }

    // MARK: mock (primitive)

    open func mockResponse(
        _ request: URLRequest,
        response: @escaping () -> MockHTTPResponse
    ) {
        useMocksOnly()
        httpMocks[request.url!.withCanonicalQueryParams!] = response
    }
}
