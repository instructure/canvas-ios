//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import SwiftUI

public class InboxViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var messages: [InboxMessageModel] = []
    @Published public private(set) var scope: InboxMessageScope = DefaultScope
    @Published public private(set) var course: String = NSLocalizedString("All Courses", comment: "")
    @Published public private(set) var courses: [GetCurrentUserCoursesRequest.CourseEntry] = []
    @Published public var isShowingScopeSelector = false
    @Published public var isShowingCourseSelector = false
    public let scopes = InboxMessageScope.allCases
    public let emptyState = (scene: SpacePanda() as PandaScene,
                             title: NSLocalizedString("No Messages", comment: ""),
                             text: NSLocalizedString("Tap the \"+\" to create a new conversation", comment: ""))

    public let errorState = (scene: NoResultsPanda() as PandaScene,
                             title: NSLocalizedString("Something Went Wrong", comment: ""),
                             text: NSLocalizedString("Pull to refresh to try again", comment: ""))

    // MARK: - Inputs
    public let refreshDidTrigger = PassthroughSubject<() -> Void, Never>()
    public let menuDidTap = PassthroughSubject<WeakViewController, Never>()
    public let scopeDidChange = CurrentValueSubject<InboxMessageScope, Never>(DefaultScope)
    public let courseDidChange = CurrentValueSubject<GetCurrentUserCoursesRequest.CourseEntry?, Never>(nil)
    public let markAsRead = PassthroughSubject<InboxMessageModel, Never>()
    public let markAsUnread = PassthroughSubject<InboxMessageModel, Never>()
    public let markAsArchived = PassthroughSubject<InboxMessageModel, Never>()

    // MARK: - Private State
    private static let DefaultScope: InboxMessageScope = .all
    private let interactor: InboxMessageInteractor
    private var subscriptions = Set<AnyCancellable>()

    public init(interactor: InboxMessageInteractor, router: Router) {
        self.interactor = interactor
        bindInputsToDataSource()
        bindDataSourceOutputsToSelf()
        bindDataSourceOutputsToSelf()
        bindUserActionsToOutputs()
        subscribeToMenuTapEvents(router: router)
    }

    private func bindUserActionsToOutputs() {
        scopeDidChange.assign(to: &$scope)
        courseDidChange
            .map { $0?.name }
            .replaceNil(with: NSLocalizedString("All Courses", comment: ""))
            .assign(to: &$course)
    }

    private func bindDataSourceOutputsToSelf() {
        interactor.state
            .assign(to: &$state)
        interactor.messages
            .assign(to: &$messages)
        interactor.courses
            .assign(to: &$courses)
    }

    private func bindInputsToDataSource() {
        courseDidChange
            .map { $0?.context }
            .removeDuplicates()
            .subscribe(interactor.setFilter)
        scopeDidChange
            .removeDuplicates()
            .subscribe(interactor.setScope)
        refreshDidTrigger
            .subscribe(interactor.triggerRefresh)
        markAsRead
            .subscribe(interactor.markAsRead)
        markAsUnread
            .subscribe(interactor.markAsUnread)
        markAsArchived
            .subscribe(interactor.markAsArchived)
    }

    private func subscribeToMenuTapEvents(router: Router) {
        menuDidTap
            .sink { [weak router] source in
                router?.route(to: "/profile", from: source, options: .modal())
            }
            .store(in: &subscriptions)
    }
}
