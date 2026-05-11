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

import BusinessLogic
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

    public static func isForceUpdateInfo(of app: AppEnvironment.App, key: String) -> Bool {
        app.forceUpdateRemoteConfigKey == key
    }

    public var shouldForceUpdate: Bool {
        let forceUpdateLogic: BusinessLogic.ForceUpdate = .live
        return forceUpdateLogic.shouldForceUpdate(
            appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            systemVersion: UIDevice.current.systemVersion,
            minimumSystemVersion: minimumSystemVersion,
            belowAppVersion: belowAppVersion
        )
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

public extension AppEnvironment.App {
    var forceUpdateRemoteConfigKey: String {
        switch self {
        case .student, .horizon: "student_force_update_info"
        case .parent: "parent_force_update_info"
        case .teacher: "teacher_force_update_info"
        }
    }

    var appID: String {
        switch self {
        case .student, .horizon: Bundle.studentAppID
        case .parent: Bundle.parentAppID
        case .teacher: Bundle.teacherAppID
        }
    }
}
