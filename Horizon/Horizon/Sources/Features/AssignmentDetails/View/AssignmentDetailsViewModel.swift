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
    // MARK: - Input / Output

    var htmlContent = ""

    // MARK: - Output

    private(set) var assignment: HAssignment?
    private(set) var isLoaderVisible = true
    private(set) var attachedFiles: [File] = []
    private(set) var submitButtonTitle = ""
    private(set) var errorMessage: String?
    private(set) var lastDraftSavedAt: String?
    private(set) var submission: HSubmission?
    private(set) var isSegmentControlVisible: Bool = false
    private(set) var selectedSubmission: AssignmentSubmissionType = .text

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()
    private var textEntryTimestamp: String?
    private var fileUploadTimestamp: String?

    var selectedSubmissionIndex: Int = 0 {
        didSet {
            selectedSubmission = AssignmentSubmissionType(index: selectedSubmissionIndex) ?? .text
            setLastDraftSavedAt()
        }
    }

    var didSubmitBefore: Bool = false {
        didSet {
            submitButtonTitle = didSubmitBefore
            ? AssignmentLocalizedKeys.newAttempt.title
            : AssignmentLocalizedKeys.submitAssignment.title
        }
    }

    var shouldEnableSubmitButton: Bool {
        guard didSubmitBefore == false else {
            // Allow submitting a new attempt.
            return true
        }
        switch selectedSubmission {
        case .text:
            return htmlContent.isNotEmpty
        case .fileUpload:
            return !attachedFiles.isEmpty
        default:
            return false
        }
    }

    // MARK: - Dependancies

    private let interactor: AssignmentInteractor
    private let textEntryInteractor: AssignmentTextEntryInteractor
    private let router: Router
    let courseID: String
    let assignmentID: String
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let didLoadAttemptCount: (String?) -> Void

    // MARK: - Init

    init(
        interactor: AssignmentInteractor,
        textEntryInteractor: AssignmentTextEntryInteractor,
        router: Router,
        courseID: String,
        assignmentID: String,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        didLoadAttemptCount: @escaping (String?) -> Void
    ) {
        self.interactor = interactor
        self.textEntryInteractor = textEntryInteractor
        self.scheduler = scheduler
        self.router = router
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.didLoadAttemptCount = didLoadAttemptCount
        bindSubmissionAssignmentEvents()
        fetchAssignmentDetails()
    }

    func viewComments(controller: WeakViewController) {
        let view = SubmissionCommentAssembly.makeView(
            courseID: courseID,
            assignmentID: assignmentID,
            attempt: 1 // TODO: Get the actual submission for the assignment, then pass submission.attempt here
        )
        let viewController = CoreHostingController(view)
        if let presentationController = viewController.sheetPresentationController {
            presentationController.detents = [.large()]
            presentationController.preferredCornerRadius = 32
        }
        router.show(viewController, from: controller, options: .modal())
    }

    // MARK: - Private Functions

    private func fetchDrafts() {
        let lastTextEntryDraft = textEntryInteractor.load()
        htmlContent = lastTextEntryDraft?.text ?? ""
        textEntryTimestamp = lastTextEntryDraft?.dateFormated
        fileUploadTimestamp = attachedFiles.first?.createdAt?.formatted(format: "d/MM, h:mm a")
    }

    private func fetchAssignmentDetails() {
        Publishers.Zip(interactor.getAssignmentDetails(), interactor.getSubmissions())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] assignmentDetails, submissions in
                self?.configAssignmentDetails(response: assignmentDetails, submissions: submissions)
            }
            .store(in: &subscriptions)
    }

    private func configAssignmentDetails(response: HAssignment, submissions: [HSubmission]) {
        isLoaderVisible = false
        assignment = response

        // This is the first time to visit the assignment & did't submit before
        isSegmentControlVisible = Set(response.assignmentSubmissionTypes) == Set([.text, .fileUpload])
        let firstSubmission = response.assignmentSubmissionTypes.first ?? .text
        selectedSubmission = isSegmentControlVisible ? .text : firstSubmission

        // In case submit before
        didSubmitBefore = !response.isUnsubmitted
        let latestSubmission = submissions.first?.type ?? .text

        selectedSubmission = didSubmitBefore ? latestSubmission : selectedSubmission
        submission = submissions.first
        didLoadAttemptCount(response.attemptCount)
    }

    private func bindSubmissionAssignmentEvents() {
        interactor.attachments
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] files in
                guard let self else {
                    return
                }
                print(files.count,"=====")

                attachedFiles = files
                fetchDrafts()
            }
            .store(in: &subscriptions)

        interactor
            .didUploadFiles
            .receive(on: scheduler)
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.fetchAssignmentDetails()
                    self?.interactor.cancelAllFiles()
                case .failure(let error):
                    self?.isLoaderVisible = false
                    self?.errorMessage = error.localizedDescription
                }
            }
            .store(in: &subscriptions)
    }

    // MARK: - Input Actions

    func addFile(url: URL) {
        interactor.addFile(url: url)
    }

    func deleteFile(file: File) {
        interactor.cancelFile(file)
    }

    func submitTextEntry() {
        interactor.submitTextEntry(with: htmlContent)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.isLoaderVisible = false
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.htmlContent = ""
                self?.textEntryInteractor.delete()
                self?.fetchAssignmentDetails()
            }
            .store(in: &subscriptions)
    }

    func saveTextEntry() {
        textEntryInteractor.save(htmlContent)
    }

    func submit() {
        guard !didSubmitBefore else {
            didSubmitBefore = false
            selectedSubmissionIndex = selectedSubmission.index
            return
        }
        isLoaderVisible = true
        switch selectedSubmission {
        case .text:
            submitTextEntry()
        case .fileUpload:
            interactor.uploadFiles()
        default:
            break
        }
    }

    private func setLastDraftSavedAt() {
        switch selectedSubmission {
        case .text:
            lastDraftSavedAt = textEntryTimestamp
        case .fileUpload:
            lastDraftSavedAt = fileUploadTimestamp
        default:
            break
        }
    }

    func deleteDraft() {
        switch selectedSubmission {
        case .text:
            textEntryInteractor.delete()
            textEntryTimestamp = nil
            lastDraftSavedAt = nil
            htmlContent = ""
        case .fileUpload:
            interactor.cancelAllFiles()
            fileUploadTimestamp = nil
            lastDraftSavedAt = nil
        default:
            break
        }
    }
}
