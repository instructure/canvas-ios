//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

enum MobileVerify {
    static var strategy: MobileVerifyStrategy = DefaultMobileVerifyStrategy()
}

protocol MobileVerifyStrategy {
    var urlString: String { get }
    var redirectUri: String { get }

    func getAuthenticationCode(client: APIVerifyClient, url: URL) -> String?
}

private struct DefaultMobileVerifyStrategy: MobileVerifyStrategy {
    let urlString = "https://sso.canvaslms.com/api/v1/mobile_verify.json"
    let redirectUri = "https://sso.canvaslms.com/canvas/login"

    func getAuthenticationCode(client: APIVerifyClient, url: URL) -> String? {
        if url.host == "sso.canvaslms.com", url.path == "/canvas/login" {
            return url.queryValue(for: "code")
        }
        return nil
    }
}

/// Though not in-use, having this defined here for later reference.
/// Using this strategy will show a intermediary screen with (Authorize, Cancel)
/// buttons. `getAuthenticationCode` returns `code` value only when tapping
/// "Authorize" button.
private struct UrnIetfMobileVerifyStrategy: MobileVerifyStrategy {
    let urlString = "https://sso.canvaslms.com/api/v1/mobile_verify.json"
    let redirectUri = "urn:ietf:wg:oauth:2.0:oob"

    func getAuthenticationCode(client: APIVerifyClient, url: URL) -> String? {
        if let baseURL = client.base_url,
           baseURL.host() == url.host,
           url.path.hasSuffix("/login/oauth2/auth") {
            return url.queryValue(for: "code")
        }
        return nil
    }
}

#if DEBUG
extension MobileVerify {
    static var defaultStrategy: MobileVerifyStrategy { DefaultMobileVerifyStrategy() }
    static var urnIetfStrategy: MobileVerifyStrategy { UrnIetfMobileVerifyStrategy() }
}
#endif
