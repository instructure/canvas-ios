//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

final class OAuthTypeTests: XCTestCase {

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let testBaseURLData = URL(string: "https://canvas.instructure.com")!
    let testClientIDData = "test_client_id"
    let testClientSecretData = "test_client_secret"
    let testCodeVerifierData = "test_code_verifier"

    func testManualOAuthAttributesFromAPIVerifyClient() {
        let verifyClient = APIVerifyClient.make(
            authorized: true,
            base_url: testBaseURLData,
            client_id: testClientIDData,
            client_secret: testClientSecretData
        )
        let attributes = ManualOAuthAttributes(client: verifyClient)

        XCTAssertEqual(attributes.baseURL, testBaseURLData)
        XCTAssertEqual(attributes.clientID, testClientIDData)
        XCTAssertEqual(attributes.clientSecret, testClientSecretData)
    }

    func testManualOAuthCodability() throws {
        let attributes = ManualOAuthAttributes(baseURL: testBaseURLData, clientID: testClientIDData, clientSecret: testClientSecretData)
        let oauthType = OAuthType.manual(attributes)

        let encodedData = try encoder.encode(oauthType)
        let decodedOAuthType = try decoder.decode(OAuthType.self, from: encodedData)

        guard case let .manual(decodedAttributes) = decodedOAuthType else {
            XCTFail("Decoded OAuthType is not manual")
            return
        }

        XCTAssertEqual(decodedAttributes.baseURL, testBaseURLData)
        XCTAssertEqual(decodedAttributes.clientID, testClientIDData)
        XCTAssertEqual(decodedAttributes.clientSecret, testClientSecretData)
    }

    func testPKCEOAuthCodability() throws {
        let attributes = PKCEOAuthAttributes(baseURL: testBaseURLData, clientID: testClientIDData, codeVerifier: testCodeVerifierData)
        let oauthType = OAuthType.pkce(attributes)

        let encodedData = try encoder.encode(oauthType)
        let decodedOAuthType = try decoder.decode(OAuthType.self, from: encodedData)

        guard case let .pkce(decodedAttributes) = decodedOAuthType else {
            XCTFail("Decoded OAuthType is not pkce")
            return
        }

        XCTAssertEqual(decodedAttributes.baseURL, testBaseURLData)
        XCTAssertEqual(decodedAttributes.clientID, testClientIDData)
        XCTAssertEqual(decodedAttributes.codeVerifier, testCodeVerifierData)
    }

    func testBaseURL() {
        let manualAttributes = ManualOAuthAttributes(baseURL: testBaseURLData, clientID: testClientIDData, clientSecret: testClientSecretData)
        let manualOAuth = OAuthType.manual(manualAttributes)
        XCTAssertEqual(manualOAuth.baseURL, testBaseURLData)

        let pkceAttributes = PKCEOAuthAttributes(baseURL: testBaseURLData, clientID: testClientIDData, codeVerifier: testCodeVerifierData)
        let pkceOAuth = OAuthType.pkce(pkceAttributes)
        XCTAssertEqual(pkceOAuth.baseURL, testBaseURLData)
    }

    func testClientID() {
        let manualAttributes = ManualOAuthAttributes(baseURL: testBaseURLData, clientID: testClientIDData, clientSecret: testClientSecretData)
        let manualOAuth = OAuthType.manual(manualAttributes)
        XCTAssertEqual(manualOAuth.clientID, testClientIDData)

        let pkceAttributes = PKCEOAuthAttributes(baseURL: testBaseURLData, clientID: testClientIDData, codeVerifier: testCodeVerifierData)
        let pkceOAuth = OAuthType.pkce(pkceAttributes)
        XCTAssertEqual(pkceOAuth.clientID, testClientIDData)

        let manualAttributesNilClientID = ManualOAuthAttributes(baseURL: testBaseURLData, clientID: nil, clientSecret: testClientSecretData)
        let manualOAuthNilClientID = OAuthType.manual(manualAttributesNilClientID)
        XCTAssertEqual(manualOAuthNilClientID.clientID, "")
    }

    func testClientSecret() {
        let manualAttributes = ManualOAuthAttributes(baseURL: testBaseURLData, clientID: testClientIDData, clientSecret: testClientSecretData)
        let manualOAuth = OAuthType.manual(manualAttributes)
        XCTAssertEqual(manualOAuth.clientSecret, testClientSecretData)

        let manualAttributesNilClientSecret = ManualOAuthAttributes(baseURL: testBaseURLData, clientID: testClientIDData, clientSecret: nil)
        let manualOAuthNilClientSecret = OAuthType.manual(manualAttributesNilClientSecret)
        XCTAssertEqual(manualOAuthNilClientSecret.clientSecret, "")
    }

    func testCodeVerifier() {
        let pkceAttributes = PKCEOAuthAttributes(baseURL: testBaseURLData, clientID: testClientIDData, codeVerifier: testCodeVerifierData)
        let pkceOAuth = OAuthType.pkce(pkceAttributes)
        XCTAssertEqual(pkceOAuth.codeVerifier, testCodeVerifierData)
    }
}
