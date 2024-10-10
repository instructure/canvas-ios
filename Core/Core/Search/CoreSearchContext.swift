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
import Combine

public class CoreSearchContext: EnvironmentKey {
    public static var defaultValue = CoreSearchContext(context: .currentUser, color: nil)

    let context: Context
    let color: UIColor?

    var didSubmit = PassthroughSubject<String, Never>()
    var searchTerm = CurrentValueSubject<String, Never>("")
    var history = CurrentValueSubject<[String], Never>([])

    weak var controller: CoreSearchController?

    public init(context: Context, color: UIColor?) {
        self.context = context
        self.color = color
    }
}

extension EnvironmentValues {

    var searchContext: CoreSearchContext {
        get { self[CoreSearchContext.self] }
        set {
            self[CoreSearchContext.self] = newValue
        }
    }
}
