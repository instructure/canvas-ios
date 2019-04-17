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

import UIKit

private class Placeholder {}

public extension Bundle {
    static let core = Bundle(for: Placeholder.self)

    static let studentBundleID = "com.instructure.icanvas"
    static let teacherBundleID = "com.instructure.ios.teacher"
    static let parentBundleID = "com.instructure.parentapp"
    static let coreBundleID = "com.instructure.core"

    func appGroupID(bundleID: String? = nil) -> String? {
        if (bundleID ?? bundleIdentifier)?.hasPrefix(Bundle.studentBundleID) == true {
            return "group.\(Bundle.studentBundleID)"
        }
        return nil
    }

    var isStudentApp: Bool { return bundleIdentifier == Bundle.studentBundleID }
    var isTeacherApp: Bool { return bundleIdentifier == Bundle.teacherBundleID }
    var isParentApp: Bool { return bundleIdentifier == Bundle.parentBundleID }
}
