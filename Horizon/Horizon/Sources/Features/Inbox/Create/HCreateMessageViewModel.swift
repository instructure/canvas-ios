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
import SwiftUI

@Observable
class HCreateMessageViewModel {
    // MARK: - Outputs
    var body: String = ""
    var cancelButtonOpacity: Double {
        sendButtonOpacity
    }
    var attachmentButtonOpacity: Double {
        attachmentViewModel.isUploading ? 0.5 : 1.0
    }
    var attachmentItems: [AttachmentItemViewModel] {
        attachmentViewModel.items
    }
    var courses: [String] = [] {
        didSet {
            selectedCourse = courses.first ?? ""
        }
    }
    var isBodyDisabled: Bool {
        isSending
    }
    var isCloseDisabled: Bool {
        isSending
    }
    var isCourseSelectionDisabled: Bool {
        isSending
    }
    var isCourseFocused: Bool = false {
        didSet {
            if isCourseFocused == true && peopleSelectionViewModel.isFocused == true {
                peopleSelectionViewModel.isFocused = false
            }
        }
    }
    var isPeopleSelectionDisabled: Bool {
        selectedCourse.isEmpty || isSending
    }
    var isSendDisabled: Bool {
        selectedCourse.isEmpty ||
            subject.trimmed().isEmpty ||
            body.trimmed().isEmpty ||
            peopleSelectionViewModel.searchByPersonSelections.isEmpty ||
            isSending ||
            attachmentViewModel.isUploading
    }
    var isSubjectDisabled: Bool {
        isSending
    }
    var selectedCourse: String = "" {
        didSet {
            peopleSelectionViewModel.clearSearch()
            if let courseID = courseID {
                peopleSelectionViewModel.context = .course(courseID)
            }
        }
    }
    var sendButtonOpacity: Double {
        isSending ? 0.0 : 1.0
    }
    var spinnerOpacity: Double {
        isSending ? 1.0 : 0.0
    }
    var subject: String = ""

    // MARK: - Private
    private var courseID: String? {
        inboxMessageInteractor.courses.value.first(where: { $0.name == selectedCourse })?.courseId
    }
    private var isSending = false
    let peopleSelectionViewModel: PeopleSelectionViewModel = .init()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Dependencies
    let attachmentViewModel: AttachmentViewModel
    private let composeMessageInteractor: ComposeMessageInteractor
    private let inboxMessageInteractor: InboxMessageInteractor
    let router: Router
    private let userID: String

    // MARK: - Initializer
    init(
        userID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        attachmentViewModel: AttachmentViewModel? = nil,
        composeMessageInteractor: ComposeMessageInteractor,
        inboxMessageInteractor: InboxMessageInteractor = InboxMessageInteractorLive(
            env: AppEnvironment.shared,
            tabBarCountUpdater: .init(),
            messageListStateUpdater: .init()
        ),
        router: Router = AppEnvironment.shared.router
    ) {
        self.userID = userID
        self.attachmentViewModel = attachmentViewModel ?? AttachmentViewModel(
            router: router,
            composeMessageInteractor: composeMessageInteractor
        )
        self.composeMessageInteractor = composeMessageInteractor
        self.inboxMessageInteractor = inboxMessageInteractor
        self.router = router

        peopleSelectionViewModel
            .isFocusedSubject
            .sink { [weak self] isFocused in
                if isFocused && self?.isCourseFocused == true {
                    self?.isCourseFocused = false
                }
            }
            .store(in: &subscriptions)

        inboxMessageInteractor
            .courses
            .map { $0.map { $0.name } }
            .sink { [weak self] courses in
                self?.courses = courses
            }
            .store(in: &subscriptions)
    }

    // MARK: - Inputs
    func attachFile(from viewController: WeakViewController) {
        attachmentViewModel.isVisible = true
    }

    func bodyFocusedChange(isFocused: Bool) {
        if !isFocused {
            body = body.trimmed()
        }
    }

    func close(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func sendMessage(viewController: WeakViewController) {
        isSending = true
        Task { [weak self] in
            await self?.sendMessage()
            await self?.refreshSentMessages()
            performUIUpdate {
                self?.close(viewController: viewController)
            }
        }
    }

    func subjectFocusedChange(isFocused: Bool) {
        if !isFocused {
            subject = subject.trimmed()
        }
    }

    // MARK: - Private Methods
    private func sendMessage() async {
        guard let courseID = courseID else {
            return
        }
        await withCheckedContinuation { continuation in
            let attachmentIds = attachmentViewModel.items.compactMap { $0.id }
            return self.composeMessageInteractor.createConversation(
                parameters: MessageParameters(
                    subject: self.subject,
                    body: self.body,
                    recipientIDs: self.peopleSelectionViewModel.recipientIDs,
                    attachmentIDs: attachmentIds,
                    context: .course(courseID),
                    bulkMessage: false
                )
            )
            .sink(
                receiveCompletion: { _ in
                    continuation.resume()
                },
                receiveValue: { _ in }
            )
            .store(in: &self.subscriptions)
        }
    }

    private func refreshSentMessages() async {
        await withCheckedContinuation { continuation in
            _ = inboxMessageInteractor.setContext(.user(userID))
            _ = self.inboxMessageInteractor.setScope(.sent)
            self.inboxMessageInteractor
                .refresh()
                .sink { _ in
                    continuation.resume()
                }
                .store(in: &self.subscriptions)
        }
    }
}
