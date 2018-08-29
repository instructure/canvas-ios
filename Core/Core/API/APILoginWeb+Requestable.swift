//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

struct LoginWebRequest: APIRequestable {
    typealias Response = String
    let clientID: String?
    let params: LoginParams

    var path: String {
        return "/login/oauth2/auth"
    }

    var query: [APIQueryItem] {
        var items: [APIQueryItem] = [
            .value("client_id", clientID ?? "" ),
            .value("response_type", "code"),
            .value("redirect_uri", "https://canvas/login&mobile=1&session_locale=\(sessionLocale())"),
        ]

        if (params.method == .forcedCanvasLogin) {
            items.append(.value("canvas_login", "1"))
        }

        // sometimes for canvas auth the authenticationProvider is an empty string
        // which causes this if to still pass and then breaks the login
        if (!params.authenticationProvider.isEmpty) {
            items.append(.value("authentication_provider", params.authenticationProvider))
        }

        return items
    }

    func sessionLocale() -> String {
        let language = NSLocale.preferredLanguages.first
        let components = language?.components(separatedBy: "-")
        return components?.first ?? ""
    }
}
