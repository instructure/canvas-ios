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

    public func appGroupID(bundleID: String? = nil) -> String? {
        if (bundleID ?? bundleIdentifier)?.hasPrefix(Bundle.studentBundleID) == true {
            return "group.\(Bundle.studentBundleID)"
        }
        return nil
    }

    public var isStudentApp: Bool { return bundleIdentifier == Bundle.studentBundleID }
    public var isTeacherApp: Bool { return bundleIdentifier == Bundle.teacherBundleID }
    public var isParentApp: Bool { return bundleIdentifier == Bundle.parentBundleID }

    public static func loadView<T: UIView>(_ type: T.Type) -> T {
        let name = String(describing: T.self)
        guard let view = Bundle(for: T.self).loadNibNamed(name, owner: T.self, options: nil)?.first as? T else {
            fatalError("Could not create \(name) from a xib.")
        }
        return view
    }

    public static func loadView<T: UIView>(for owner: T) {
        let name = String(describing: T.self)
        guard let view = Bundle(for: T.self).loadNibNamed(name, owner: owner, options: nil)?.first as? UIView else {
            fatalError("Could not load first view from \(name) xib.")
        }
        owner.addSubview(view)
        view.pin(inside: owner)
    }

    public static func loadController<T: UIViewController>(_ type: T.Type) -> T {
        let name = String(describing: T.self)
        let storyboard = UIStoryboard(name: name, bundle: Bundle(for: T.self))
        guard let view = storyboard.instantiateViewController(withIdentifier: name) as? T else {
            fatalError("Could not create \(name) from a storyboard.")
        }
        return view
    }
}
