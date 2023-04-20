//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
import CombineExt
import Foundation

public class AboutViewModel: ObservableObject {
    public static let DefaultEntries: [AboutInfoEntry] = [
        .app(),
        .domain(),
        .loginID(),
        .email(),
        .version(),
    ]
    public let title = NSLocalizedString("About", comment: "")
    public let entries: [AboutInfoEntry]

    private var subscriptions = Set<AnyCancellable>()

    public init(entries: [AboutInfoEntry] = DefaultEntries) {
        self.entries = entries

        let observerStore = ReactiveStore(useCase: GetCourseListCourses(enrollmentState: .active))
        observerStore.observeEntities(forceFetch: true, loadAllPages: true)
            .sink { entities in
                print("👋 observeEntities: ", entities)
            }
            .store(in: &subscriptions)

        let isLoading = PassthroughRelay<Bool>()

        isLoading
            .sink(receiveValue: { val in
                print("💎 isLoading: ", val)
            })
            .store(in: &subscriptions)

        let fetchOnceStore = ReactiveStore(useCase: GetCourseListCourses(enrollmentState: .invited_or_pending))
        fetchOnceStore.getEntities()
            .bindProgress(isLoading)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { entities in
                    print("🈯️ getEntities: ", entities)
                }
            )
            .store(in: &subscriptions)
    }
}
