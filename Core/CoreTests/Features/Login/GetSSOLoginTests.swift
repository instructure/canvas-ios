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

class GetSSOLoginTest: CoreTestCase {
    func testInit() {
        XCTAssertNil(GetSSOLogin(url: URL(string: "https://nope.nope/nope")!, app: .student))
        XCTAssertNil(GetSSOLogin(url: URL(string: "https://sso.canvaslms.com/nope")!, app: .student))
        XCTAssertNil(GetSSOLogin(url: URL(string: "https://sso.canvaslms.com/canvas/login")!, app: .student))
        XCTAssertNil(GetSSOLogin(url: URL(string: "https://sso.canvaslms.com/canvas/login?code=&domain=")!, app: .student))
        XCTAssertNotNil(GetSSOLogin(url: URL(string: "https://sso.canvaslms.com/canvas/login?code=c&domain=d")!, app: .student))
        let login = GetSSOLogin(url: URL(string: "https://sso.beta.canvaslms.com/canvas/login?code=c&domain=d")!, app: .student)
        XCTAssertEqual(login?.code, "c")
        XCTAssertEqual(login?.domain, "d")
    }

    func testFetch() {
        let login = GetSSOLogin(url: URL(string: "https://sso.beta.canvaslms.com/canvas/login?code=code&domain=canvas.instructure.com")!, app: .student)!
        var entry: LoginSession?
        var error: Error?
        let callback = { (session: LoginSession?, err: Error?) in
            entry = session
            error = err
        }
        login.fetch(callback)
        XCTAssertNil(entry)
        XCTAssertNil(error)

        api.mock(GetMobileVerifyRequest(domain: "canvas.instructure.com"), error: NSError.internalError())
        login.fetch(callback)
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
        XCTAssertNil(entry)
        XCTAssertNil(error)

        api.mock(PostLoginOAuthRequest(client: client, code: "code"), error: NSError.internalError())
        login.fetch(callback)
        XCTAssertNil(entry)
        XCTAssertNotNil(error)

        api.mock(PostLoginOAuthRequest(client: client, code: "code"), value: .make(
            accessToken: "t",
            refreshToken: nil,
            tokenType: "type",
            user: APIOAuthUser.init(id: "1", name: "u", effective_locale: "en", email: nil),
            expiresIn: 10
        ))
        login.fetch(callback)
        XCTAssertEqual(entry?.accessToken, "t")
        XCTAssertEqual(entry?.userID, "1")
        XCTAssertEqual(entry?.clientID, "id")
        XCTAssertEqual(entry?.clientSecret, "sec")
        XCTAssertNil(error)
    }

    func testFetchWithMasqueradeResponse() {
        let client = APIVerifyClient(
            authorized: true,
            base_url: URL(string: "https://canvas.instructure.com"),
            client_id: "id",
            client_secret: "sec"
        )
        api.mock(GetMobileVerifyRequest(domain: "canvas"), value: client)
        api.mock(PostLoginOAuthRequest(client: client, code: "code"), value: .make(
            accessToken: "t",
            refreshToken: nil,
            tokenType: "type",
            user: APIOAuthUser.init(id: "1", name: "u", effective_locale: "en", email: nil),
            realUser: APIOAuthToken.RealUser(id: "2", name: "real user"),
            expiresIn: 10
        ))
        let login = GetSSOLogin(url: URL(string: "https://sso.canvaslms.com/canvas/login?code=code&domain=canvas")!, app: .student)!
        var session: LoginSession?
        var error: Error?
        login.fetch {
            session = $0
            error = $1
        }
        XCTAssertEqual(session?.actAsUserID, "1")
        XCTAssertEqual(session?.originalUserID, "2")
        XCTAssertNil(error)
    }

    func testCodeForApp() {
        var code = GetSSOLogin.codeForApp(.student)
        XCTAssertEqual(code, "code")
        code = GetSSOLogin.codeForApp(.teacher)
        XCTAssertEqual(code, "code_ios_teacher")
        code = GetSSOLogin.codeForApp(.parent)
        XCTAssertEqual(code, "code")
    }
}
