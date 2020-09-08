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

public struct SessionDefaults {
    private var userDefaults: UserDefaults {
        return UserDefaults(suiteName: Bundle.main.appGroupID()) ?? .standard
    }

    private var sessionDefaults: [String: Any]? {
        get { return userDefaults.dictionary(forKey: sessionID) }
        set { userDefaults.set(newValue, forKey: sessionID) }
    }

    public let sessionID: String

    public var submitAssignmentCourseID: String? {
        get { return self["submitAssignmentCourseID"] as? String }
        set { self["submitAssignmentCourseID"] = newValue }
    }

    public var submitAssignmentID: String? {
        get { return self["submitAssignmentID"] as? String }
        set { self["submitAssignmentID"] = newValue }
    }

    public var tokenExpires: Bool? {
        get { return self["tokenExpires"] as? Bool }
        set { self["tokenExpires"] = newValue }
    }

    public var showGradesOnDashboard: Bool? {
        get { return self["showGradesOnDashboard"] as? Bool }
        set { self["showGradesOnDashboard"] = newValue }
    }

    public var landingPath: String? {
        mutating get {
            if let landingPath = self["landingPath"] as? String {
                return landingPath
            }
            if let legacy = (UserDefaults.standard.object(forKey: "landingPageSettings") as? [String: String])?.first?.value {
                let map = [
                    "Courses": "/",
                    "Calendar": "/calendar",
                    "To-Do List": "/to-do",
                    "Notifications": "/notifications",
                    "Messages": "/conversations",
                ]
                if let path = map[legacy] {
                    landingPath = path
                    return path
                }
            }
            return nil
        }
        set { self["landingPath"] = newValue }
    }

    public var limitWebAccess: Bool? {
        get { self["limitWebAccess"] as? Bool }
        set { self["limitWebAccess"] = newValue }
    }

    public var parentCurrentStudentID: String? {
        get { self["parentCurrentStudentID"] as? String }
        set { self["parentCurrentStudentID"] = newValue }
    }

    public var parentColorScheme: [String: Int]? {
        get { self["parentColorScheme"] as? [String: Int] }
        set { self["parentColorScheme"] = newValue }
    }

    public var hasSetPSPDFKitLastUsedValues: Bool {
        get { return self["hasSetPSPDFKitLastUsedValues"] as? Bool ?? false }
        set { self["hasSetPSPDFKitLastUsedValues"] = newValue }
    }

    public mutating func reset() {
        sessionDefaults = nil
    }

    private subscript(key: String) -> Any? {
        get { return sessionDefaults?[key] }
        set {
            var defaults = sessionDefaults ?? [:]
            if let value = newValue {
                defaults[key] = value
            } else {
                defaults.removeValue(forKey: key)
            }
            sessionDefaults = defaults
        }
    }
}
