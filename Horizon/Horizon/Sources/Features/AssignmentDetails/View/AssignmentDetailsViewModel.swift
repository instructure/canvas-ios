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

import Combine
import CombineSchedulers
import Core
import Observation

@Observable
final class AssignmentDetailsViewModel {
    // MARK: - Input

    private(set) var submissionEvents = PassthroughSubject<AssignmentSubmissionView.Events, Never>()
    var isSubmitButtonVisible = false
    var selectedSubmission: AssignmentType?

    // MARK: - Input / Output

    var isAlertVisible = false

    // MARK: - Output

    private(set) var assignment: HAssignment?
    private(set) var isLoaderVisible = true
    private(set) var didSubmitAssignment = false
    private(set) var attachments: [File] = []
    private(set) var errorMessage = ""
    private(set) var htmlContent = ""
    var isSubmitButtonDisabled: Bool {
        let selectedSubmission = selectedSubmission ?? .textEntry
        switch selectedSubmission {
        case .textEntry:
            return htmlContent.isEmpty
        case .uploadFile:
            return attachments.isEmpty
        }
    }

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependancies

    private let interactor: AssignmentInteractor
    private let router: Router
    private let courseID: String
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    deinit {
        interactor.cancelAllFiles()
    }

    init(
        interactor: AssignmentInteractor,
        router: Router,
        courseID: String,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.scheduler = scheduler
        self.router = router
        self.courseID = courseID
        fetchAssignmentDetails()
        bindSubmissionAssignmentEvents()
    }

    // MARK: - Input Actions

    func presentRichContentEditor(controller: WeakViewController) {
        let richContentEditor = TextSubmissionViewController.create(htmlContent: htmlContent, courseID: courseID)
        /// Switch the `selectedSubmission` to nil and then back to `.textEntry` after retrieving the HTML content, to reflect the height for webView.
        selectedSubmission = nil
        richContentEditor.didSetHtmlContent = { [weak self] html in
            self?.htmlContent = html
            self?.selectedSubmission = .textEntry
        }
        router.show(richContentEditor, from: controller, options: .modal(isDismissable: false, embedInNav: true))
    }
    
    func viewComments(controller: WeakViewController) {
        let view = SubmissionCommentAssembly.makeView(
            courseID: courseID,
            assignmentID: assignment?.id ?? "",
            attempt: 1
        )
        let viewController = CoreHostingController(view)
        if let presentationController = viewController.sheetPresentationController {
            presentationController.detents = [.large()]
            presentationController.preferredCornerRadius = 32
        }
        router.show(viewController, from: controller, options: .modal())
    }

    // MARK: - Private Functions

    private func fetchAssignmentDetails() {
        interactor.getAssignmentDetails()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.isLoaderVisible = false
                self?.assignment = response
            }
            .store(in: &subscriptions)
    }

    private func bindSubmissionAssignmentEvents() {
        submissionEvents.sink { [weak self] event in
            guard let self else {
                return
            }
            switch event {
            case .onTextEntry:
                submitTextEntry()
            case .uploadFile(url: let url):
                interactor.addFile(url: url)
            case .sendFileTapped:
                isLoaderVisible = true
                interactor.uploadFiles()
            case .deleteFile(file: let file):
                interactor.cancelFile(file)
            }
        }
        .store(in: &subscriptions)

        interactor.attachments
            .receive(on: scheduler)
            .sink { [weak self] values in
                self?.attachments = values
            }
            .store(in: &subscriptions)

        interactor
            .didUploadFiles
            .receive(on: scheduler)
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.isLoaderVisible = false
                    self?.didSubmitAssignment = true
                case .failure(let error):
                    self?.isLoaderVisible = false
                    self?.isAlertVisible = true
                    self?.errorMessage = error.localizedDescription
                }
            }
            .store(in: &subscriptions)
    }

    private func submitTextEntry() {
        isLoaderVisible = true
        interactor.submitTextEntry(with: htmlContent)
            .sink { [weak self] completion in
                self?.isLoaderVisible = false
                if case .failure(let error) = completion {
                    self?.isAlertVisible = true
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.didSubmitAssignment = true
            }
            .store(in: &subscriptions)
    }
}
