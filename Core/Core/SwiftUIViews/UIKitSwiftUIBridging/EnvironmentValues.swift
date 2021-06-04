//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

extension AppEnvironment: EnvironmentKey {
    public static var defaultValue: AppEnvironment { AppEnvironment.shared }
}

extension UIViewController: EnvironmentKey {
    public static var defaultValue: WeakViewController { WeakViewController() }
}

struct ContainerWidth: EnvironmentKey {
    public static var defaultValue: CGFloat { 0 }
}

extension EnvironmentValues {
    public var appEnvironment: AppEnvironment {
        get { self[AppEnvironment.self] }
        set { self[AppEnvironment.self] = newValue }
    }

    public var viewController: WeakViewController {
        get { self[UIViewController.self] }
        set { self[UIViewController.self] = newValue }
    }

    public var containerWidth: CGFloat {
        get { self[ContainerWidth.self] }
        set { self[ContainerWidth.self] = newValue }
    }
}
