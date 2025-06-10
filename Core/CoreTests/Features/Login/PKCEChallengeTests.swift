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

@testable import Core
import XCTest

final class PKCEChallengeTests: XCTestCase {
    func testGenerateChallenge() {
        let pkceChallenge = PKCEChallenge()
        let challengePair = pkceChallenge.generateChallenge(length: 50)

        XCTAssertNotNil(challengePair)
        XCTAssertEqual(challengePair?.codeVerifier.count, 50)
        XCTAssertFalse(challengePair?.codeChallenge.isEmpty ?? true)

        // Verify the challenge has proper S256 base64url encoding format
        // No padding characters, uses - and _ instead of + and /
        XCTAssertFalse(challengePair?.codeChallenge.contains("=") ?? false)
        XCTAssertFalse(challengePair?.codeChallenge.contains("+") ?? false)
        XCTAssertFalse(challengePair?.codeChallenge.contains("/") ?? false)
    }

    func testGenerateChallengeDefaultLength() {
        let pkceChallenge = PKCEChallenge()
        let challengePair = pkceChallenge.generateChallenge()

        XCTAssertNotNil(challengePair)
        XCTAssertEqual(challengePair?.codeVerifier.count, 43)
    }

    func testCodeVerifierContainsOnlyAllowedCharacters() {
        let pkceChallenge = PKCEChallenge()
        let challengePair = pkceChallenge.generateChallenge()

        let verifier = challengePair?.codeVerifier ?? ""
        let allowedCharSet = CharacterSet(charactersIn: PKCEChallenge.allowedChars)
        let verifierCharSet = CharacterSet(charactersIn: verifier)

        XCTAssertTrue(verifierCharSet.isSubset(of: allowedCharSet))
    }

    func testGenerateChallengeDifferentResults() {
        let pkceChallenge = PKCEChallenge()
        let pair1 = pkceChallenge.generateChallenge()
        let pair2 = pkceChallenge.generateChallenge()

        XCTAssertNotNil(pair1)
        XCTAssertNotNil(pair2)
        XCTAssertNotEqual(pair1?.codeVerifier, pair2?.codeVerifier)
        XCTAssertNotEqual(pair1?.codeChallenge, pair2?.codeChallenge)
    }

    func testChallengePairStruct() {
        let verifier = "test_verifier"
        let challenge = "test_challenge"
        let pair = PKCEChallenge.ChallengePair(codeVerifier: verifier, codeChallenge: challenge)

        XCTAssertEqual(pair.codeVerifier, verifier)
        XCTAssertEqual(pair.codeChallenge, challenge)
    }
}
