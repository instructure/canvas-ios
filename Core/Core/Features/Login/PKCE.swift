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

import CommonCrypto
import Foundation

class PKCEChallenge {
    struct ChallengePair {
        let codeVerifier: String
        let codeChallenge: String
    }

    // Allowed characters as per RFC7636 https://datatracker.ietf.org/doc/html/rfc7636
    static let allowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"

    /// Generates a code verifier for the given length from the allowed char set.
    /// - Parameter length: The length of the verifier between (43 and 128). Defaults to 43.
    /// - Returns: A code verifier
    private func generateCodeVerifier(length: Int) -> String {
        String((0 ..< length).map { _ in Self.allowedChars.randomElement()! })
    }

    /// Generates a PKCE challenge pair
    /// - Parameter length: The length of the verifier between (43 and 128). Defaults to 43.
    /// - Returns: PKCE challenge pair
    func generateChallenge(length: Int = 43) -> PKCEChallenge.ChallengePair? {
        let verifier = generateCodeVerifier(length: length)
        guard let data = verifier.data(using: .utf8) else { return nil }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }

        let challenge = Data(hash).base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")

        return ChallengePair(
            codeVerifier: verifier,
            codeChallenge: challenge
        )
    }
}
