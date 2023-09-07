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

import UIKit

private class Placeholder {}

public extension Bundle {
    @objc static let core = Bundle(for: Placeholder.self)

    static let studentBundleID = "com.instructure.icanvas.2u"
    static let teacherBundleID = "com.instructure.ios.teacher"
    static let parentBundleID = "com.instructure.parentapp"

    static let coreBundleID = "com.instructure.core.2u"

    static let studentUITestsBundleID = "com.instructure.StudentUITests.xctrunner"
    static let teacherUITestsBundleID = "com.instructure.TeacherUITests.xctrunner"
    static let parentUITestsBundleID = "com.instructure.ParentUITests.xctrunner"

    static let studentE2ETestsBundleID = "com.instructure.StudentE2ETests.xctrunner"
    static let teacherE2ETestsBundleID = "com.instructure.TeacherE2ETests.xctrunner"
    static let parentE2ETestsBundleID = "com.instructure.ParentE2ETests.xctrunner"

    func appGroupID(bundleID: String? = nil) -> String? {
        if (bundleID ?? bundleIdentifier)?.hasPrefix(Bundle.studentBundleID) == true {
            return "group.\(Bundle.studentBundleID)"
        }
        return nil
    }

    var appBundleIdentifier: String { bundleIdentifier ?? "com.instructure.app" }
    var isStudentApp: Bool { bundleIdentifier == Bundle.studentBundleID || isStudentTestsRunner }
    var isTeacherApp: Bool { bundleIdentifier == Bundle.teacherBundleID || isTeacherTestsRunner }
    var isParentApp: Bool { bundleIdentifier == Bundle.parentBundleID || isParentTestsRunner }
    var isStudentTestsRunner: Bool { [Bundle.studentUITestsBundleID, Bundle.studentE2ETestsBundleID].contains(bundleIdentifier) }
    var isTeacherTestsRunner: Bool { [Bundle.teacherUITestsBundleID, Bundle.teacherE2ETestsBundleID].contains(bundleIdentifier) }
    var isParentTestsRunner: Bool { [Bundle.parentUITestsBundleID, Bundle.parentE2ETestsBundleID].contains(bundleIdentifier) }
    var testTargetBundleID: String? {
        if isStudentTestsRunner {
            return Bundle.studentBundleID
        } else if isTeacherTestsRunner {
            return Bundle.teacherBundleID
        } else if isParentTestsRunner {
            return Bundle.parentBundleID
        } else {
            return bundleIdentifier
        }
    }
    static var isExtension: Bool { Bundle.main.bundleURL.pathExtension == "appex" }

    var pandataAppName: String {
        switch bundleIdentifier {
        case Bundle.studentBundleID:
            return "Canvas Student for iOS"
        case Bundle.teacherBundleID:
            return "Canvas Teacher for iOS"
        default:
            return "Invalid App ID for iOS"
        }
    }

    var pandataAppTag: String {
        switch bundleIdentifier {
        case Bundle.studentBundleID, Bundle.studentUITestsBundleID, Bundle.studentE2ETestsBundleID:
            return "CANVAS_STUDENT_IOS"
        case Bundle.teacherBundleID, Bundle.teacherUITestsBundleID, Bundle.teacherE2ETestsBundleID:
            return "CANVAS_TEACHER_IOS"
        default:
            return "Invalid AppTag for iOS"
        }
    }
}

// The comment parameter is necessary for -exportLocalizations to find these
internal func NSLocalizedString(_ key: String, comment: String) -> String {
    return NSLocalizedString(key, bundle: .core, comment: comment)
}
