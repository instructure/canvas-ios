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

public enum UserAgent: CustomStringConvertible {
    case `default`
    case safari

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
            let systemVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
            return "Mozilla/5.0 (iPhone; CPU iPhone OS \(systemVersion) like Mac OS X) AppleWebKit/603.1.23 (KHTML, like Gecko) Version/10.0 Mobile/14E5239e Safari/602.1"
        }
    }
}
