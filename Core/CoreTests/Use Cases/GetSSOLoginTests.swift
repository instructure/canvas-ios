//
// Copyright (C) 2019-present Instructure, Inc.
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
@testable import Core

class GetSSOLoginTest: CoreTestCase {
    func testInit() {
        XCTAssertNil(GetSSOLogin(url: URL(string: "https://nope.nope/nope")!))
        XCTAssertNil(GetSSOLogin(url: URL(string: "https://sso.canvaslms.com/nope")!))
        XCTAssertNil(GetSSOLogin(url: URL(string: "https://sso.canvaslms.com/canvas/login")!))
        XCTAssertNil(GetSSOLogin(url: URL(string: "https://sso.canvaslms.com/canvas/login?code=&domain=")!))
        XCTAssertNotNil(GetSSOLogin(url: URL(string: "https://sso.canvaslms.com/canvas/login?code=c&domain=d")!))
        let login = GetSSOLogin(url: URL(string: "https://sso.beta.canvaslms.com/canvas/login?code=c&domain=d")!)
        XCTAssertEqual(login?.code, "c")
        XCTAssertEqual(login?.domain, "d")
    }

    func testFetch() {
        let login = GetSSOLogin(url: URL(string: "https://sso.beta.canvaslms.com/canvas/login?code=code&domain=canvas.instructure.com")!)!
        var entry: KeychainEntry?
        var error: Error?
        let callback = { (session: KeychainEntry?, err: Error?) in
            entry = session
            error = err
        }
        login.fetch(callback)
        waitForMainAsync()
        XCTAssertNil(entry)
        XCTAssertNil(error)

        api.mock(GetMobileVerifyRequest(domain: "canvas.instructure.com"), error: NSError.internalError())
        login.fetch(callback)
        waitForMainAsync()
        XCTAssertNil(entry)
        XCTAssertNotNil(error)

        let client = APIVerifyClient(
            authorized: true,
            base_url: URL(string: "https://canvas.instructure.com"),
            client_id: "id",
            client_secret: "sec"
        )
        api.mock(GetMobileVerifyRequest(domain: "canvas.instructure.com"), value: client)
        login.fetch(callback)
        waitForMainAsync()
        XCTAssertNil(entry)
        XCTAssertNil(error)

        api.mock(PostLoginOAuthRequest(client: client, code: "code"), error: NSError.internalError())
        login.fetch(callback)
        waitForMainAsync()
        XCTAssertNil(entry)
        XCTAssertNotNil(error)

        api.mock(PostLoginOAuthRequest(client: client, code: "code"), value: .init(
            access_token: "t",
            refresh_token: nil,
            token_type: "type",
            user: APIOAuthUser.init(id: "1", name: "u", effective_locale: "en", email: nil),
            expires_in: 10
        ))
        login.fetch(callback)
        waitForMainAsync()
        XCTAssertEqual(entry?.accessToken, "t")
        XCTAssertEqual(entry?.userID, "1")
        XCTAssertNil(error)
    }
}
