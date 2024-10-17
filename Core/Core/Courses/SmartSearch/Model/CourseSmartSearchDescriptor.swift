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
    private let featureFlags: Store<GetEnabledFeatureFlags>
    private var subscriptions = Set<AnyCancellable>()

    public init(env: AppEnvironment, context: Context) {
        self.context = context
        self.featureFlags = env.subscribe(GetEnabledFeatureFlags(context: context))

        featureFlags
            .allObjects
            .map({ fetched in
                return fetched.contains(where: { $0.name == "smart_search" })
            })
            .subscribe(enabledSubject)
            .store(in: &subscriptions)

        featureFlags
            .refresh(force: true)
    }

    private var enabledSubject = CurrentValueSubject<Bool, Never>(false)
    public var enabledPublished: AnyPublisher<Bool, Never> {
        enabledSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    public func filterEditorView(_ filter: Binding<CourseSmartSearchFilter?>) -> some View {
        CourseSmartSearchFilterEditorView(
            filter: filter.wrappedValue,
            onSubmit: { newSelection in
                filter.wrappedValue = newSelection
            }
        )
    }

    public var support: SearchSupportOption<some SearchSupportAction>? {
        return SearchSupportOption(
            action: SearchSupportSheet(content: CourseSmartSearchHelpView())
        )
    }

    public func searchDisplayView(_ filter: Binding<CourseSmartSearchFilter?>) -> some View {
        CourseSmartSearchDisplayView(filter: filter)
    }
}
