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

public protocol SearchViewAttributes {
    associatedtype Environment: SearchViewEnvironment where Environment.Attributes == Self
    typealias EnvironmentKey = SearchEnvironmentKey<Self>

    static var `default`: Self { get }

    var searchPrompt: String { get }
    var accentColor: UIColor? { get }
}

extension SearchViewAttributes {
    var accentColor: UIColor? { nil }
}

// MARK: - Environment Property

public protocol SearchViewEnvironment {
    associatedtype Attributes: SearchViewAttributes

    typealias EnvKeyPath = WritableKeyPath<EnvironmentValues, SearchViewContext<Attributes>>

    static var keyPath: EnvKeyPath { get }
}

public struct SearchEnvironmentKey<Attributes: SearchViewAttributes>: EnvironmentKey {
    public static var defaultValue: SearchViewContext<Attributes> {
        return SearchViewContext<Attributes>(attributes: .default)
    }
}
