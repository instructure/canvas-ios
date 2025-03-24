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
    @Published public private(set) var course: String = String(localized: "All Courses", bundle: .core)
    @Published public private(set) var courses: [InboxCourse] = []
    @Published public private(set) var hasNextPage = false
    @Published public var isShowingScopeSelector = false
    @Published public var isShowingCourseSelector = false
    @Published public var isShowMenuButton: Bool = true
    public let snackBarViewModel = SnackBarViewModel()
    public let scopes = InboxMessageScope.allCases
    public let emptyState = (scene: SpacePanda() as PandaScene,
                             title: String(localized: "No Messages", bundle: .core),
                             text: String(localized: "Tap the \"+\" to create a new conversation", bundle: .core))

    public let errorState = (scene: NoResultsPanda() as PandaScene,
                             title: String(localized: "Something Went Wrong", bundle: .core),
                             text: String(localized: "Pull to refresh to try again", bundle: .core))

    // MARK: - Inputs
    public let refreshDidTrigger = PassthroughSubject<() -> Void, Never>()
    public let menuDidTap = PassthroughSubject<WeakViewController, Never>()
    public let newMessageDidTap = PassthroughSubject<WeakViewController, Never>()
    public let messageDidTap = PassthroughSubject<(messageID: String, controller: WeakViewController), Never>()
    public let scopeDidChange = CurrentValueSubject<InboxMessageScope, Never>(DefaultScope)
    public let courseDidChange = CurrentValueSubject<InboxCourse?, Never>(nil)
    public let updateState = PassthroughSubject<(messageId: String, state: ConversationWorkflowState), Never>()
    public let contentDidScrollToBottom = PassthroughSubject<Void, Never>()
    public let didTapStar = PassthroughSubject<(Bool, String), Never>()

    // MARK: - Private State
    private static let DefaultScope: InboxMessageScope = .inbox
    private let messageInteractor: InboxMessageInteractor
    private let favouriteInteractor: InboxMessageFavouriteInteractor
    private let inboxSettingsInteractor: InboxSettingsInteractor
    private var subscriptions = Set<AnyCancellable>()
    private var isLoadingNextPage = CurrentValueSubject<Bool, Never>(false)
    private var didSendMailSuccessfully = PassthroughSubject<Void, Never>()

    // MARK: - Init
    public init(
        messageInteractor: InboxMessageInteractor,
        favouriteInteractor: InboxMessageFavouriteInteractor,
        inboxSettingsInteractor: InboxSettingsInteractor,
        router: Router
    ) {
        self.messageInteractor = messageInteractor
        self.favouriteInteractor = favouriteInteractor
        self.inboxSettingsInteractor = inboxSettingsInteractor
        self.isShowMenuButton = !messageInteractor.isParentApp
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
            .replaceNil(with: String(localized: "All Courses", bundle: .core))
            .assign(to: &$course)

        let interactor = self.messageInteractor
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
        messageInteractor.state
            .assign(to: &$state)
        messageInteractor.messages
            .map { messages in
                messages.map {
                    InboxMessageListItemViewModel(message: $0)
                }
            }
            .assign(to: &$messages)
        messageInteractor.courses
            .assign(to: &$courses)
        messageInteractor.hasNextPage
            .assign(to: &$hasNextPage)

        // Prefetch inbox settings value so cached value will be loaded on the compose screen
        inboxSettingsInteractor.signature
            .sink()
            .store(in: &subscriptions)
    }

    private func bindInputsToDataSource() {
        let interactor = self.messageInteractor
        courseDidChange
            .map { $0?.context }
            .removeDuplicates()
            .map { interactor.setContext($0) }
            .sink()
            .store(in: &subscriptions)
        scopeDidChange
            .removeDuplicates()
            .map { interactor.setScope($0) }
            .flatMap { _ in
                interactor.refresh()
                    .receive(on: DispatchQueue.main)
            }
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

        didTapStar
            .flatMap { [favouriteInteractor] starred, messageId in
                favouriteInteractor.updateStarred(to: starred, messageId: messageId)
            }
            .flatMap { [messageInteractor] _ in
                messageInteractor.refresh()
                    .receive(on: DispatchQueue.main)
            }
            .sink()
            .store(in: &subscriptions)

        didSendMailSuccessfully
            .sink { [weak self] in
                self?.snackBarViewModel.showSnack(InboxMessageScope.sent.localizedName)
            }
            .store(in: &subscriptions)
    }

    private func subscribeToTapEvents(router: Router) {
        menuDidTap
            .sink { [router] source in
                router.route(to: "/profile", from: source, options: .modal())
            }
            .store(in: &subscriptions)
        newMessageDidTap
            .sink { [router, didSendMailSuccessfully, messageInteractor] source in
                // In the parent app we need a different logic for student context picker
                if messageInteractor.isParentApp {
                    if let bottomSheet = router.match("/conversations/new_message") {
                        router.show(bottomSheet, from: source, options: .modal())
                    }
                } else {
                    router.show(
                        ComposeMessageAssembly.makeComposeMessageViewController(sentMailEvent: didSendMailSuccessfully),
                        from: source,
                        options: .modal(.automatic, isDismissable: false, embedInNav: true, addDoneButton: false, animated: true)
                    )
                }
            }
            .store(in: &subscriptions)
        messageDidTap
            .flatMap { [weak self] (messageID, controller) in
                let message = self?.messageInteractor.messages.value.first {
                    $0.messageId == messageID
                }
                guard let message, let self, message.state != .archived else { return Just((messageID, controller)).eraseToAnyPublisher() }

                return self.messageInteractor.updateState(message: message, state: .read).map {
                    (messageID, controller)
                }.eraseToAnyPublisher()
            }
            .sink { [router, scopeDidChange] (messageID, controller) in
                let openedFromSentFilter = scopeDidChange.value == .sent
                router.route(
                    to: "/conversations/\(messageID)",
                    userInfo: ["allowArchive": !openedFromSentFilter],
                    from: controller,
                    options: .detail
                )
            }
            .store(in: &subscriptions)
    }
}
