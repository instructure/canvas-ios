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

public protocol SearchViewsProvider {
    associatedtype Filter
    associatedtype FilterEditor: View
    associatedtype Support: SearchSupportAction
    associatedtype SearchContent: View

    var support: SearchSupportButtonModel<Support>? { get }

    func contentView(_ filter: Binding<Filter?>) -> SearchContent
    func filterEditorView(_ filter: Binding<FilterSelection<Filter>>) -> FilterEditor
}

public struct FilterSelection<Filter>: ReferrableValue {
    public static var defaultValue: FilterSelection<Filter> { .init() }

    public var editedFilter: Filter?
    public var submitted: ((Filter?) -> Void)?

    internal var presented: Bool = false
    private var cancelled: Bool = false

    mutating func present(with initialValue: Filter?) {
        editedFilter = initialValue
        cancelled = false
        presented = true
    }

    public mutating func cancel() {
        cancelled = true
    }

    public mutating func submit() {
        submitted?(editedFilter)
    }

    func resolve(with target: Binding<Filter?>) {
        guard cancelled == false else { return }
        target.wrappedValue = editedFilter
    }

    func resolve(with submitChange: (Filter?) -> Void) {
        guard cancelled == false else { return }
        submitChange(editedFilter)
    }
}
