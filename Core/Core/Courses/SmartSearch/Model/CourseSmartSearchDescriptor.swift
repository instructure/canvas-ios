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

public class CourseSmartSearchDescriptor: SearchDescriptor {

    private let context: Context
    private let interactor: CourseSmartSearchInteractor

    public init(context: Context, interactor: CourseSmartSearchInteractor? = nil) {
        self.context = context
        self.interactor = interactor ?? CourseSmartSearchInteractorLive()
    }

    public var isEnabled: AnyPublisher<Bool, Never> {
        interactor
            .isEnabled(context: context)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func filterEditorView(_ filter: Binding<CourseSmartSearchFilter?>) -> some View {
        CourseSmartSearchFilterEditorView(
            model: CourseSearchFilterEditorViewModel(
                filter: filter.wrappedValue,
                onSubmit: { newSelection in
                    filter.wrappedValue = newSelection
                }
            )
        )
    }

    public var support: SearchSupportOption<some SearchSupportAction>? {
        return SearchSupportOption(
            action: SearchSupportSheet(content: CourseSmartSearchHelpView())
        )
    }

    public func searchDisplayView(_ filter: Binding<CourseSmartSearchFilter?>) -> some View {
        CourseSmartSearchDisplayView(
            viewModel: CourseSmartSearchViewModel(context: context, interactor: interactor),
            filter: filter
        )
    }
}
