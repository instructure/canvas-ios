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

import Foundation
import Combine
import CombineExt

class InboxCoursePickerViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var favoriteCourses: [Course] = []
    @Published public private(set) var moreCourses: [Course] = []
    @Published public private(set) var groups: [Group] = []
    @Published public private(set) var state: StoreState = .loading

    // MARK: - Input / Output
    @Published public var selectedRecipientContext: RecipientContext?

    // MARK: - Inputs
    public private(set) var dismissViewDidTrigger = PassthroughSubject<Void, Never>()
    public private(set) var refreshDidTrigger = PassthroughSubject<() -> Void, Never>()
    var didSelect: ((RecipientContext) -> Void)

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: InboxCoursePickerInteractor

    public init(interactor: InboxCoursePickerInteractor,
                selected: RecipientContext? = nil,
                didSelect: @escaping ((RecipientContext) -> Void)) {
        self.interactor = interactor
        self.selectedRecipientContext = selected
        self.didSelect = didSelect

        setupOutputBindings()
    }

    public func onSelect(selected: Course) {
        let context = RecipientContext(course: selected)
        onSelect(selected: context)
    }

    public func onSelect(selected: Group) {
        let context = RecipientContext(group: selected)
        onSelect(selected: context)
    }

    public func onSelect(selected: RecipientContext) {
        self.selectedRecipientContext = selected
        didSelect(selected)
    }

    public func refresh() async {
        return await withCheckedContinuation { continuation in
            interactor.refresh().sink(
                receiveCompletion: {_ in
                    continuation.resume()
                }, receiveValue: { _ in }
            )
            .store(in: &subscriptions)
        }
    }

    private func setupOutputBindings() {
        interactor.state
            .assign(to: &$state)
        interactor.favoriteCourses
            .assign(to: &$favoriteCourses)
        interactor.moreCourses
            .assign(to: &$moreCourses)
        interactor.groups
            .assign(to: &$groups)
    }

}
