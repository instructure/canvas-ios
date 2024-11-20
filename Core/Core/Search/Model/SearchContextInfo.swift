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

public protocol SearchContextInfo {
    typealias EnvironmentKey = SearchEnvironmentKey<Self>
    typealias EnvironmentKeyPath = WritableKeyPath<EnvironmentValues, SearchContext<Self>>

    static var environmentKeyPath: EnvironmentKeyPath { get }
    static var defaultInfo: Self { get }

    var searchPrompt: String { get }
    var accentColor: UIColor? { get }
}

extension SearchContextInfo {
    var accentColor: UIColor? { nil }
}

// MARK: - Environment Property

public struct SearchEnvironmentKey<Info: SearchContextInfo>: EnvironmentKey {
    public static var defaultValue: SearchContext<Info> {
        return SearchContext<Info>(info: .defaultInfo)
    }
}
