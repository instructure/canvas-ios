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
    @Published public private(set) var messages: [InboxMessageListItemViewModel] = []
    @Published public private(set) var scope: InboxMessageScope = DefaultScope
    @Published public private(set) var course: String = NSLocalizedString("All Courses", comment: "")
    @Published public private(set) var courses: [InboxCourse] = []
    @Published public private(set) var hasNextPage = false
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
    public let messageDidTap = PassthroughSubject<(messageID: String, controller: WeakViewController), Never>()
    public let scopeDidChange = CurrentValueSubject<InboxMessageScope, Never>(DefaultScope)
    public let courseDidChange = CurrentValueSubject<InboxCourse?, Never>(nil)
    public let updateState = PassthroughSubject<(messageId: String, state: ConversationWorkflowState), Never>()
    public let contentDidScrollToBottom = PassthroughSubject<Void, Never>()

    // MARK: - Private State
    private static let DefaultScope: InboxMessageScope = .all
    private let interactor: InboxMessageInteractor
    private var subscriptions = Set<AnyCancellable>()
    private var isLoadingNextPage = CurrentValueSubject<Bool, Never>(false)

    public init(interactor: InboxMessageInteractor, router: Router) {
        self.interactor = interactor
        bindInputsToDataSource()
        bindDataSourceOutputsToSelf()
        bindUserActionsToOutputs()
        subscribeToTapEvents(router: router)
    }

    private func bindUserActionsToOutputs() {
        scopeDidChange
            .assign(to: &$scope)
        courseDidChange
            .map { $0?.name }
            .replaceNil(with: NSLocalizedString("All Courses", comment: ""))
            .assign(to: &$course)

        let interactor = self.interactor
        let isLoadingNextPage = self.isLoadingNextPage

        contentDidScrollToBottom
            .filter { interactor.hasNextPage.value && !isLoadingNextPage.value }
            .handleEvents(receiveOutput: { isLoadingNextPage.send(true) })
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .flatMap { interactor.loadNextPage() }
            .sink { isLoadingNextPage.send(false) }
            .store(in: &subscriptions)
    }

    private func bindDataSourceOutputsToSelf() {
        interactor.state
            .assign(to: &$state)
        interactor.messages
            .map { messages in
                messages.map {
                    InboxMessageListItemViewModel(message: $0)
                }
            }
            .assign(to: &$messages)
        interactor.courses
            .assign(to: &$courses)
        interactor.hasNextPage
            .assign(to: &$hasNextPage)
    }

    private func bindInputsToDataSource() {
        let interactor = self.interactor
        courseDidChange
            .map { $0?.context }
            .removeDuplicates()
            .map { interactor.setContext($0) }
            .sink()
            .store(in: &subscriptions)
        scopeDidChange
            .removeDuplicates()
            .map { interactor.setScope($0) }
            .sink()
            .store(in: &subscriptions)
        refreshDidTrigger
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .flatMap { refreshCompletion in
                interactor
                    .refresh()
                    .receive(on: DispatchQueue.main)
                    .handleEvents(receiveOutput: { refreshCompletion() })
            }
            .sink()
            .store(in: &subscriptions)
        updateState
            .compactMap { (messageId, state) -> (message: InboxMessageListItem, state: ConversationWorkflowState)? in
                // Since the UI doesn't work directly with CoreData objects we must retreive it by its id
                let message = interactor.messages.value.first {
                    $0.messageId == messageId
                }
                guard let message = message else {
                    return nil
                }
                return (message: message, state: state)
            }
            .map { interactor.updateState(message: $0.message, state: $0.state) }
            .sink()
            .store(in: &subscriptions)
    }

    private func subscribeToTapEvents(router: Router) {
        menuDidTap
            .sink { [router] source in
                router.route(to: "/profile", from: source, options: .modal())
            }
            .store(in: &subscriptions)
        messageDidTap
            .sink { [router] (messageID, controller) in
                router.route(to: "/conversations/\(messageID)", from: controller, options: .detail)
            }
            .store(in: &subscriptions)
    }
}
