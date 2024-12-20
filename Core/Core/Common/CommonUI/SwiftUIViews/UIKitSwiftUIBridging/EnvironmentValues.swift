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

struct ViewControllerKey: EnvironmentKey {
    public static var defaultValue: WeakViewController { WeakViewController() }
}

struct ContainerSize: EnvironmentKey {
    public static var defaultValue: CGSize { .zero }
}

struct HorizontalPadding: EnvironmentKey {
    public static var defaultValue: CGFloat { 0 }
}

extension EnvironmentValues {
    public var appEnvironment: AppEnvironment {
        get { self[AppEnvironment.self] }
        set { self[AppEnvironment.self] = newValue }
    }

    public var viewController: WeakViewController {
        get { self[ViewControllerKey.self] }
        set { self[ViewControllerKey.self] = newValue }
    }

    /**
     This environment value can be used to pass a size read with GeometryReader down the view hierarchy.
     */
    public var containerSize: CGSize {
        get { self[ContainerSize.self] }
        set { self[ContainerSize.self] = newValue }
    }

    /**
     Useful for passing the expected horizontal padding to child views if padding cannot be set on the root view for some reason.
     */
    public var horizontalPadding: CGFloat {
        get { self[HorizontalPadding.self] }
        set { self[HorizontalPadding.self] = newValue }
    }
}
