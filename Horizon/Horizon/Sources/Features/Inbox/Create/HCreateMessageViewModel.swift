//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import Combine
import CombineSchedulers
import Observation
import Foundation

@Observable
final class HCreateMessageViewModel {
    // MARK: - Inputs / Outputs

    var body: String = ""
    var subject: String = ""
    var isCourseFocused: Bool = false
    var isSending = false

    // MARK: - Outputs

    private(set) var courses: [String] = []
    var attachmentItems: [AttachmentFileModel] { attachmentViewModel.items }
    var isSendDisabled: Bool {
        selectedCourse.isEmpty ||
        subject.trimmed().isEmpty ||
        body.trimmed().isEmpty ||
        recipientSelectionViewModel.searchByPersonSelections.isEmpty ||
        isSending ||
        attachmentViewModel.isUploading
    }

    var selectedCourse: String = "" {
        didSet {
            recipientSelectionViewModel.clearSearch()
            recipientSelectionViewModel.isFocusedSubject.accept(false)
            if let courseID {
                recipientSelectionViewModel.setContext(.course(courseID))
            }
        }
    }

    // MARK: - Private

    private var subscriptions: Set<AnyCancellable> = []
    private var courseID: String? {
        inboxMessageInteractor.courses.value.first(where: { $0.name == selectedCourse })?.courseId
    }

    // MARK: - Dependencies

    let recipientSelectionViewModel: RecipientSelectionViewModel
    let attachmentViewModel: AttachmentViewModel
    private let composeMessageInteractor: ComposeMessageInteractor
    private let inboxMessageInteractor: InboxMessageInteractor
    private let router: Router
    private let userID: String
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Initializer

    init(
        userID: String,
        attachmentViewModel: AttachmentViewModel,
        recipientSelectionViewModel: RecipientSelectionViewModel,
        composeMessageInteractor: ComposeMessageInteractor,
        inboxMessageInteractor: InboxMessageInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.userID = userID
        self.recipientSelectionViewModel = recipientSelectionViewModel
        self.attachmentViewModel = attachmentViewModel
        self.composeMessageInteractor = composeMessageInteractor
        self.inboxMessageInteractor = inboxMessageInteractor
        self.router = router
        self.scheduler = scheduler

        recipientSelectionViewModel
            .isFocusedSubject
            .receive(on: scheduler)
            .sink { [weak self] _ in
                self?.isCourseFocused = false
            }
            .store(in: &subscriptions)

        inboxMessageInteractor
            .courses
            .map { $0.map { $0.name } }
            .receive(on: scheduler)
            .sink { [weak self] courses in
                self?.courses = courses
                self?.selectedCourse = courses.first.defaultToEmpty
            }
            .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func attachFile(from viewController: WeakViewController) {
        attachmentViewModel.isVisible = true
    }

    func close(viewController: WeakViewController) {
        // Need to delete the files if dismissed the view
        attachmentViewModel.deleteAll()
        router.dismiss(viewController)
    }

    func sendMessage(viewController: WeakViewController) {
        isSending = true
        sendMessage()
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self else {
                    return Just(()).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.refreshSentMessages()
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error)
                }
            } receiveValue: { [weak self] _ in
                self?.router.dismiss(viewController)
            }
            .store(in: &subscriptions)
    }

    // MARK: - Private Methods

    private func sendMessage() -> AnyPublisher<URLResponse?, Error> {
        guard let courseID else {
            return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let attachmentIds = attachmentViewModel.items.compactMap { $0.id }
        return composeMessageInteractor.createConversation(
            parameters: MessageParameters(
                subject: subject,
                body: body,
                recipientIDs: recipientSelectionViewModel.recipientIDs,
                attachmentIDs: attachmentIds,
                context: .course(courseID),
                bulkMessage: false
            )
        )
        .eraseToAnyPublisher()
    }

    private func refreshSentMessages() -> AnyPublisher<Void, Never> {
        inboxMessageInteractor
            .setContext(.user(userID))
            .flatMap { [inboxMessageInteractor] in
                inboxMessageInteractor.setScope(.sent)
            }
            .flatMap { [inboxMessageInteractor] in
                inboxMessageInteractor.refresh()
            }
            .eraseToAnyPublisher()
    }
}
