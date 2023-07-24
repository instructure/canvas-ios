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

class MessageDetailsViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var subject: String = ""
    @Published public private(set) var messages: [MessageViewModel] = []
    @Published public private(set) var starred: Bool = false

    public let title = NSLocalizedString("Message Details", comment: "")

    // MARK: - Inputs
    public let refreshDidTrigger = PassthroughSubject<() -> Void, Never>()
    public let starDidTap = PassthroughSubject<Bool, Never>()

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: MessageDetailsInteractor
    private let router: Router
    private let myID: String

    public init(router: Router, interactor: MessageDetailsInteractor, myID: String) {
        self.interactor = interactor
        self.router = router
        self.myID = myID

        setupOutputBindings()
        setupInputBindings(router: router)
    }

    public func moreTapped(viewController: WeakViewController) {
        let sheet = BottomSheetPickerViewController.create()
        sheet.addAction(
            image: .replyLine,
            title: NSLocalizedString("Reply", bundle: .core, comment: ""),
            accessibilityIdentifier: "MessageDetails.reply"
        ) {}
        sheet.addAction(
            image: .replyAllLine,
            title: NSLocalizedString("Reply All", bundle: .core, comment: ""),
            accessibilityIdentifier: "MessageDetails.replyAll"
        ) {}

        sheet.addAction(
            image: .forwardLine,
            title: NSLocalizedString("Forward", bundle: .core, comment: ""),
            accessibilityIdentifier: "MessageDetails.markAllRead"
        ) {}

        sheet.addAction(
            image: .archiveLine,
            title: NSLocalizedString("Archive", bundle: .core, comment: ""),
            accessibilityIdentifier: "MessageDetails.archive"
        ) {}

        sheet.addAction(
            image: .trashLine,
            title: NSLocalizedString("Delete", bundle: .core, comment: ""),
            accessibilityIdentifier: "MessageDetails.delete"
        ) {}
        router.show(sheet, from: viewController, options: .modal())
    }

    public func replyTapped(viewController: WeakViewController) {}

    private func setupOutputBindings() {
        interactor.state
                .assign(to: &$state)
        interactor.subject
            .assign(to: &$subject)
        interactor.messages
            .map { messages in
                messages.map {
                    MessageViewModel(item: $0, myID: self.myID, userMap: self.interactor.userMap)
                }
            }
            .assign(to: &$messages)
        interactor.starred
            .assign(to: &$starred)
    }

    private func setupInputBindings(router: Router) {
        let interactor = self.interactor
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
        starDidTap
            .map { starred in
                interactor.updateStarred(starred: starred) }
            .sink()
            .store(in: &subscriptions)
    }
}
