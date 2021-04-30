//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import UIKit

public enum UserAgent: CustomStringConvertible {
    case `default`
    case safari
    case desktopSafari

    public func productNameForBundle(_ id: String?) -> String {
        switch id {
        case Bundle.teacherBundleID:
            return "iosTeacher"
        case Bundle.parentBundleID:
            return "iosParent"
        default:
            return "iCanvas"
        }
    }

    public var description: String {
        switch self {
        case .default:
            let product = productNameForBundle(Bundle.main.bundleIdentifier)
            let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
            let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
            return "\(product)/\(shortVersion) (\(bundleVersion)) \(UIDevice.current.model)/\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        case .safari:
            let version = UIDevice.current.systemVersion
            let os = version.replacingOccurrences(of: ".", with: "_")
            return "Mozilla/5.0 (iPhone; CPU iPhone OS \(os) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(version) Mobile/15E148 Safari/604.1"
        case .desktopSafari:
            return "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15"
        }
    }

    public var customUserAgentName: String? {
        switch self {
        case .safari:
            let version = UIDevice.current.systemVersion
            return "Version/\(version) Safari/604.1"
        default:
            return nil
        }
    }
}
