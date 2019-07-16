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
import CanvasCore

class SettingsAPIClient {
    private let ephemeralSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
    static var shared: SettingsAPIClient = SettingsAPIClient()

    func addPairingCode(_ session: Session, observerID: String, pairingCode: String, handler: ((String?) -> Void)?) throws {
        let path = "/api/v1/users/\(observerID)/observees"
        let parameters: [String: Any] = ["pairing_code": pairingCode]

        let request = try session.POST(path, parameters: parameters)
        let task = ephemeralSession.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode >= 300,
                let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                var errorMessage: String? = NSLocalizedString("An Error Occurred", comment: "")
                if let errorContainer: ErrorContainer = try? decoder.decode(ErrorContainer.self, from: data),
                    let msg = errorContainer.errors.first?.message {
                    errorMessage = msg
                }
                handler?(errorMessage)
                return
            }
            handler?(nil)
        }
        task.resume()
    }

    private struct ErrorContainer: Decodable {
        var errors: [Error]
    }

    private struct Error: Decodable {
        var message: String
    }

}
