//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import SwiftUI

private struct IsTeacherKey: EnvironmentKey {
    static var defaultValue: Bool { Bundle.main.isTeacherApp }
}

private class ViewControllerKey: EnvironmentKey {
    static var defaultValue: () -> UIViewController? = { nil }
}

@available(iOSApplicationExtension 13.0, *)
extension EnvironmentValues {
    var isTeacher: Bool {
        get { self[IsTeacherKey.self] }
        set { self[IsTeacherKey.self] = newValue }
    }
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironment.self] }
        set { self[AppEnvironment.self] = newValue }
    }
    var viewController: () -> UIViewController? {
        get { self[ViewControllerKey.self] }
        set { self[ViewControllerKey.self] = newValue }
    }
}
