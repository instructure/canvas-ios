//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct AboutInfoEntry: Identifiable, Equatable {
    public static let UnknownLabel = "-"

    public let id: String
    public let a11yLabel: String
    public let title: String
    public let label: String

    public init(title: String, label: String) {
        self.id = title
        self.a11yLabel = "\(title),\(label == Self.UnknownLabel ? String(localized: "Unknown", bundle: .core) : label)"
        self.title = title
        self.label = label
    }
}

public extension AboutInfoEntry {
    static func app(_ app: AppEnvironment.App? = AppEnvironment.shared.app) -> Self {
        var appName = UnknownLabel

        if let app {
            appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Degrees edX"
        }

        return Self(title: String(localized: "App", bundle: .core),
                    label: appName)
    }
}

public extension AboutInfoEntry {
    static func domain(_ session: LoginSession? = AppEnvironment.shared.currentSession) -> Self {
        Self(title: String(localized: "Domain", bundle: .core),
                    label: session?.baseURL.absoluteString ?? UnknownLabel)
    }
}

public extension AboutInfoEntry {
    static func loginID(_ session: LoginSession? = AppEnvironment.shared.currentSession) -> Self {
        Self(title: String(localized: "Login ID", bundle: .core),
                    label: session?.userID ?? UnknownLabel)
    }
}

public extension AboutInfoEntry {
    static func email(_ session: LoginSession? = AppEnvironment.shared.currentSession) -> Self {
        Self(title: String(localized: "Email", bundle: .core),
             label: session?.userEmail ?? UnknownLabel)
    }
}

public extension AboutInfoEntry {
    static func version(_ bundle: Bundle = Bundle.main) -> Self {
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? UnknownLabel
        return Self(title: String(localized: "Version", bundle: .core),
                    label: version)
    }
}
