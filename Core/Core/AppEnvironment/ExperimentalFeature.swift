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

/// An experimental or in-development feature
///
/// An `ExperimentalFeature` flag is useful for including code in production
/// that is not ready for all users to exercise. This is different from
/// feature flags in Canvas, which represent optional functionality in
/// production that should only apply to certain accounts, courses, or people.
public enum ExperimentalFeature: String, CaseIterable, Codable {
    case favoriteGroups = "favorite_groups"
    case graphqlSpeedGrader = "graphql_speed_grader"
    case refreshTokens = "refresh_tokens"
    case nativeDashboard = "native_dashboard"
    case qrLoginTeacher = "qr_code_login_teacher"
    case qrLoginParent = "qr_code_login_parent"
    case qrLoginStudent = "qr_code_login_student"
    case nativeStudentInbox = "native_student_inbox"
    case nativeTeacherInbox = "native_teacher_inbox"
    case studentQRCodePairing = "student_qr_code_pairing"
    case parentQRCodePairing = "parent_qr_code_pairing"

    public var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: userDefaultsKey) }
        nonmutating set { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) }
    }

    public var userDefaultsKey: String {
        return "ExperimentalFeature.\(self.rawValue)"
    }

    public static var allEnabled: Bool {
        get { ExperimentalFeature.allCases.allSatisfy({ $0.isEnabled }) }
        set { ExperimentalFeature.allCases.forEach({ $0.isEnabled = newValue }) }
    }
}
