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

import Foundation
import XCTest
@testable import Core

open class UITestCase: XCTestCase {
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let pasteboardType = "com.instructure.ui-test-helper"

    open override func tearDown() {
        super.tearDown()
        send(.tearDown)
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
        send(.login, KeychainEntry(
            accessToken: token,
            baseURL: baseURL,
            expiresAt: nil,
            locale: "en",
            refreshToken: nil,
            userID: "",
            userName: ""
        ))
    }

    open func logInEntry(_ entry: KeychainEntry) {
        send(.login, entry)
    }

    open func logInUser(_ user: UITestUser) {
        if let entry = user.keychainEntry {
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
        user.keychainEntry = currentSession()
    }

    open func currentSession() -> KeychainEntry? {
        send(.currentSession)
        guard
            let data = UIPasteboard.general.data(forPasteboardType: pasteboardType),
            let helper = try? decoder.decode(UITestHelpers.Helper.self, from: data),
            helper.type == .currentSession, let entryData = helper.data
        else { return nil }
        return try? decoder.decode(KeychainEntry.self, from: entryData)
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
        mockDataRequest(URLRequest(url: URL(string: path, relativeTo: api.baseURL)!), data: data, response: response, error: error, noCallback: noCallback)
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
}
