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
import SQLite3
@testable import Core

open class CoreUITestCase: XCTestCase {
    let decoder = JSONDecoder()
    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    open var homeScreen: Element {
        if Bundle.main.isParentApp {
            return TabBar.coursesTab
        } else {
            return TabBar.dashboardTab
        }
    }

    open var httpMocks = [URL: (URLRequest) -> MockHTTPResponse]()
    open var graphQLMocks = [String: (URLRequest) -> Data]()
    var useMocks: Bool {
        switch Bundle.main.bundleIdentifier {
        case Bundle.studentUITestsBundleID,
             Bundle.teacherUITestsBundleID,
             Bundle.parentUITestsBundleID:
            return true
        default:
            return false
        }
    }

    open var user: UITestUser? {
        switch Bundle.main.bundleIdentifier {
        case Bundle.studentE2ETestsBundleID:
            return .readStudent1
        case Bundle.teacherE2ETestsBundleID:
            return .readTeacher1
        default:
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

    public static var needsLaunch = true
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
        if useMocks {
            mockEncodableRequest("/login/oauth2/token", value: [String]())
        }
        reset()
        send(.enableExperimentalFeatures(experimentalFeatures))

        if case .passThruAndLog(toPath: let logPath) = missingMockBehavior {
            // Clear old log
            try? FileManager.default.removeItem(atPath: logPath)
        }
        if let user = user {
            logInUser(user)
        }
    }

    open override func tearDown() {
        send(.tearDown)
        LoginSession.clearAll()
        super.tearDown()
    }

    public enum MissingMockBehavior {
        case failTest
        case allow

        // To be used during test writing only. Will forward the request to the network,
        // and also write the request/response in plain text to the log file
        case passThruAndLog(toPath: String)
    }
    open var missingMockBehavior: MissingMockBehavior = .failTest

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
                    print("mock not found for url (\(request.httpMethod ?? "GET")):\n  \(url.absoluteString)")
                    return try? encoder.encode(testCase.handleMissingMock(request))
                }
                return try? encoder.encode(mock(request))
            }
        }
    }
    static let delegate = ServerDelegate()

    func handleMissingMock(_ request: URLRequest) -> MockHTTPResponse {
        switch missingMockBehavior {
        case .failTest:
            XCTFail("missing mock: \(request.url?.absoluteString ?? "???")")
            fallthrough
        case .allow:
            return MockHTTPResponse(errorMessage: "unmocked")
        case let .passThruAndLog(toPath: path):
            let requestFinished = XCTestExpectation(description: "pass-thru request")
            var serverResponse: MockHTTPResponse?
            URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                serverResponse = MockHTTPResponse(
                    data: data,
                    http: response as? HTTPURLResponse,
                    errorMessage: error.map { "\($0)" }
                )
                requestFinished.fulfill()
            }).resume()
            wait(for: [requestFinished], timeout: 60)
            if !FileManager.default.fileExists(atPath: path) {
                FileManager.default.createFile(atPath: path, contents: nil)
            }
            let handle = FileHandle(forUpdatingAtPath: path)!
            defer { handle.closeFile() }
            handle.seekToEndOfFile()
            func writeLine(_ line: Any) {
                handle.write("\(line)\n".data(using: .utf8)!)
            }
            writeLine("--- \(request.httpMethod ?? "GET") ---")
            writeLine(request.url!)
            if let body = request.httpBody {
                if let str = String(data: body, encoding: .utf8) {
                    writeLine(str.replacingOccurrences(of: "\\n", with: "\n"))
                } else {
                    writeLine(body)
                }
            }
            writeLine("--- RESPONSE \(serverResponse?.http?.statusCode ?? 0) ---")
            if let data = serverResponse?.data {
                if let json = try? JSONSerialization.jsonObject(with: data),
                    let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    handle.write(data)
                    writeLine("")
                } else if let str = String(data: data, encoding: .utf8) {
                    writeLine(str)
                } else if let url = serverResponse?.dataSavedToTemporaryFileURL {
                    writeLine(url)
                } else {
                    writeLine("nil")
                }
            }
            writeLine("--- END ---\n")
            return serverResponse!
        }
    }

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
        send(.reset(useMocks: useMocks))
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

    open func handleAlert(withTexts texts: [String]? = nil, byPressingButton button: String) {
        let alert = app.find(type: .alert).waitToExist()
        if let texts = texts {
            let textElements = alert.rawElement.descendants(matching: .staticText)
            let alertTexts = textElements.allElementsBoundByIndex.map { $0.label }
            XCTAssertEqual(alertTexts, texts)
        }
        alert.rawElement.find(label: button).waitToExist().tap()
        alert.waitToVanish()
    }

    open func allowAccessToPhotos(block: () -> Void) {
        _ = setSimulatorPermission(.photos)
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
        _ = setSimulatorPermission(.microphone)
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

    public enum Permission: String, CaseIterable {
        case photos = "kTCCServicePhotos"
        case microphone = "kTCCServiceMicrophone"
    }

    // Don't rely on this, it won't work on device. It does make simulator tests more reliable
    open func setSimulatorPermission(_ permission: Permission, allowed: Bool = true) -> Bool {
        let dbPath = Bundle.main.bundlePath + "/../../../../../Library/TCC/TCC.db"
        XCTAssert(FileManager.default.fileExists(atPath: dbPath), "couldn't find TCC.db")

        var db: OpaquePointer?
        let service = permission.rawValue
        let client = Bundle.main.testTargetBundleID!
        let query = """
        delete from access where service = '\(service)' and client = '\(client)';
        insert into
        access (service, client, client_type, allowed, prompt_count, csreq, policy_id)
        values('\(service)', '\(client)', 0, \(allowed ? 1 : 0), 0, 0, 0);
        """
        print(query)
        guard sqlite3_open(dbPath, &db) == SQLITE_OK else { return false }
        defer { sqlite3_close(db) }
        var err: UnsafeMutablePointer<Int8>?
        guard sqlite3_exec(db, query, nil, nil, &err) == SQLITE_OK else {
            let msg = err.map { String(cString: $0) } ?? "unknown error"
            print("Error setting permission: \(msg)")
            return false
        }
        return true
    }

    // MARK: mock (convenience)

    open func mockData<R: APIRequestable>(
        _ requestable: R,
        value: R.Response? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false
    ) {
        let data = value.flatMap { try! Self.encoder.encode($0) }
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
        let data = value.flatMap { try! Self.encoder.encode($0) }
        let api = URLSessionAPI()
        let url = URL(string: path, relativeTo: api.baseURL.appendingPathComponent("api/v1/"))!
        mockURL(url, data: data, response: response, error: error, noCallback: noCallback)
    }

    open func mockGraphQL(operationName: String, _ json: Any) {
        mockGraphQL(operationName: operationName) { _ in
            try! JSONSerialization.data(withJSONObject: json)
        }
    }

    open func mockGraphQL<R: APIGraphQLRequestable>(_ requestable: R, value: R.Response) {
        mockGraphQL(operationName: requestable.operationName) { _ in
            try! Self.encoder.encode(value)
        }
    }

    open func mockGraphQL(operationName: String, dynamicData: @escaping (URLRequest) -> Data) {
        let api = URLSessionAPI()
        let url = URL(string: "/api/graphql", relativeTo: api.baseURL)!
        graphQLMocks[operationName] = dynamicData
        mockURL(url, dynamicData: doGraphQLMock)
    }

    open func doGraphQLMock(request: URLRequest) -> Data {
        guard let body = request.httpBody,
            let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
            let operationName = json["operationName"] as? String,
            let mock = graphQLMocks[operationName] else {
                if let body = request.httpBody,
                    let bodyStr = String(data: body, encoding: .utf8) {
                    print("body = \(bodyStr)")
                } else {
                    print("body = \(String(describing: request.httpBody))")
                }
                XCTFail("couldn't find graphQL mock")
                fatalError()
        }

        return mock(request)
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
        mockData(GetCourseRequest(courseID: course.id, include: [
            .courseImage,
            .favorites,
            .permissions,
            .sections,
            .term,
        ]), value: course)
        mockData(GetEnabledFeatureFlagsRequest(context: ContextModel(.course, id: course.id)), value: [
            "rce_enhancements",
            "new_gradebook",
        ])
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

    open var baseEnrollment: APIEnrollment {
        .make(
            type: Bundle.main.isTeacherTestsRunner ? "TeacherEnrollment" : "StudentEnrollment",
            role: Bundle.main.isTeacherTestsRunner ? "TeacherEnrollment" : "StudentEnrollment"
        )
    }
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
        dynamicData: @escaping (URLRequest) -> Data
    ) {
        mockResponse(URLRequest(url: url)) { request in
            let data = dynamicData(request)
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
        mockResponse(request, response: { _ in mockHTTPResponse })
    }

    // MARK: mock (primitive)

    open func mockResponse(
        _ request: URLRequest,
        response: @escaping (URLRequest) -> MockHTTPResponse
    ) {
        XCTAssert(useMocks, "Mocks not allowed for E2E tests!")
        httpMocks[request.url!.withCanonicalQueryParams!] = response
    }

    open func mockNow(_ date: Date) {
        Clock.mockNow(date)
        send(.mockNow(date))
    }
}
