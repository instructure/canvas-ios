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

public enum APIError: Error {
    public static func from(data: Data?, response: URLResponse?, error: Error) -> Error {
        if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let message = json["message"] as? String, !message.isEmpty {
                return NSError.instructureError(message)
            }
            if let list = json["errors"] as? [[String: Any]], !list.isEmpty {
                let message = list.map { $0["message"] as? String ?? "" } .joined(separator: "\n")
                return NSError.instructureError(message)
            }
            if let dict = json["errors"] as? [String: Any], !dict.isEmpty {
                let message = dict.map { _, error in
                    return error as? String ??
                        (error as? [String])?.first ??
                        (error as? [String: Any])?["message"] as? String ??
                        (error as? [[String: Any]])?.first?["message"] as? String ??
                        embeddedDict(error) ??
                        ""
                } .joined(separator: "\n")
                return NSError.instructureError(message)
            }
        }
        if let status = (response as? HTTPURLResponse)?.statusCode, status >= 400 {
            return NSError.instructureError(NSLocalizedString("There was an unexpected error. Please try again.", bundle: .core, comment: ""))
        }
        return error
    }

    private static func embeddedDict( _ dict: Any?) -> String? {
        guard let d = dict as? [String: Any], let arr = d.first?.value as? [[String: Any]], let embeddedDict = arr.first else { return nil }
        guard let attr = embeddedDict["attribute"] as? String, let msg = embeddedDict["message"] as? String else { return nil}
        return "\(attr): \(msg)"
    }
}
