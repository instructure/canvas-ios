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
import UIKit.UIDevice

public struct ForceUpdateInfo: Codable {
    private let belowAppVersion: String
    private let minimumSystemVersion: String
    public let isDismissable: Bool

    public init?(data: Data) {
        do {
            self = try JSONDecoder().decode(ForceUpdateInfo.self, from: data)
        } catch {
            return nil
        }
    }

    public static func isForceUpdateInfo(_ key: String) -> Bool {
        key == "force_update_info"
    }

    public var shouldForceUpdate: Bool {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return false }
        let systemVersion = UIDevice.current.systemVersion

        return systemVersion.compare(minimumSystemVersion, options: .numeric) != .orderedAscending
            && appVersion.compare(belowAppVersion, options: .numeric) == .orderedAscending
    }
}

public extension ForceUpdateInfo {
    private static let userDefaultsKey = "force_update_info"

    private static var sharedUserDefaults: UserDefaults {
        UserDefaults(suiteName: Bundle.main.appGroupID()) ?? .standard
    }

    func saveToUserDefaults() {
        Self.sharedUserDefaults.set(try? JSONEncoder().encode(self), forKey: Self.userDefaultsKey)
    }

    static func fromUserDefaults() -> ForceUpdateInfo? {
        guard let data = Self.sharedUserDefaults.data(forKey: userDefaultsKey) else { return nil }
        return ForceUpdateInfo(data: data)
    }
}
