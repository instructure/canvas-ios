//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public struct CourseSmartSearchViewAttributes: SearchViewAttributes {
    public typealias Environment = CourseSmartSearchViewEnvironment

    public static var `default`: CourseSmartSearchViewAttributes {
        return CourseSmartSearchViewAttributes(context: .currentUser, color: nil)
    }

    let context: Context
    public private(set) var accentColor: UIColor?

    public init(context: Context, color: UIColor?) {
        self.context = context
        self.accentColor = color
    }

    public var searchPrompt: String {
        String(localized: "Search in this course", bundle: .core)
    }
}

// MARK: - Environment

public enum CourseSmartSearchViewEnvironment: SearchViewEnvironment {
    public typealias Attributes = CourseSmartSearchViewAttributes
    public static var keyPath: EnvKeyPath { \.courseSmartSearchContext }
}

extension EnvironmentValues {
    var courseSmartSearchContext: SearchViewContext<CourseSmartSearchViewAttributes> {
        get { self[CourseSmartSearchViewAttributes.EnvironmentKey.self] }
        set { self[CourseSmartSearchViewAttributes.EnvironmentKey.self] = newValue }
    }
}
