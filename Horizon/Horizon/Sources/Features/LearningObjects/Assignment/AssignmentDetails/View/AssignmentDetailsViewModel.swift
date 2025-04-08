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
import Foundation
import Observation

@Observable
final class AssignmentDetailsViewModel {
    // MARK: - Input / Output

    var htmlContent = "" {
        didSet {
            if isStartTyping {
                saveTextEntry()
                lastDraftSavedAt = textEntryInteractor.load()?.dateFormated
            }
        }
    }

    var isOverlayToolsPresented = false

    // MARK: - Output

    private(set) var assignment: HAssignment?
    private(set) var isLoaderVisible = true
    private(set) var isMarkAsDoneLoaderVisible = false
    private(set) var attachedFiles: [File] = []
    private(set) var submitButtonTitle = ""
    private(set) var errorMessage: String?
    private(set) var lastDraftSavedAt: String?
    private(set) var submission: HSubmission?
    private(set) var isSegmentControlVisible: Bool = false
    private(set) var selectedSubmission: AssignmentSubmissionType = .text
    private(set) var externalURL: URL?
    var isStartTyping = false
    var assignmentPreference: AssignmentPreferenceKeyType?
    var isSubmitButtonHidden: Bool {
        assignment?.submissionTypes.contains(.none) == true && assignment?.submissionTypes.count == 1
    }

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()
    private var textEntryTimestamp: String?
    private var fileUploadTimestamp: String?
    private var submissions: [HSubmission] = []
    var selectedSubmissionIndex: Int = 0 {
        didSet {
            selectedSubmission = AssignmentSubmissionType(index: selectedSubmissionIndex)
            setLastDraftSavedAt()
        }
    }

    var hasSubmittedBefore: Bool = false {
        didSet {
            submitButtonTitle = hasSubmittedBefore ? AssignmentLocalizedKeys.newAttempt.title : AssignmentLocalizedKeys.submitAssignment.title
        }
    }

    var shouldEnableSubmitButton: Bool {
        guard hasSubmittedBefore == false else {
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

    let courseID: String
    let assignmentID: String
    let isShowMarkAsDoneButton: Bool
    private(set) var isCompletedItem: Bool
    private let moduleID: String
    private let itemID: String
    private let interactor: AssignmentInteractor
    private let moduleItemInteractor: ModuleItemSequenceInteractor
    private let textEntryInteractor: AssignmentTextEntryInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var onTapAssignmentOptions: PassthroughSubject<Void, Never>
    private let didLoadAssignment: (String?, HModuleItem) -> Void

    // MARK: - Init

    init(
        interactor: AssignmentInteractor,
        moduleItemInteractor: ModuleItemSequenceInteractor,
        textEntryInteractor: AssignmentTextEntryInteractor,
        isMarkedAsDone: Bool,
        isCompletedItem: Bool,
        moduleID: String,
        itemID: String,
        router: Router,
        courseID: String,
        assignmentID: String,
        onTapAssignmentOptions: PassthroughSubject<Void, Never>,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        didLoadAssignment: @escaping (String?, HModuleItem) -> Void
    ) {
        self.interactor = interactor
        self.moduleItemInteractor = moduleItemInteractor
        self.textEntryInteractor = textEntryInteractor
        self.isShowMarkAsDoneButton = isMarkedAsDone
        self.isCompletedItem = isCompletedItem
        self.moduleID = moduleID
        self.itemID = itemID
        self.onTapAssignmentOptions = onTapAssignmentOptions
        self.scheduler = scheduler
        self.router = router
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.didLoadAssignment = didLoadAssignment
        bindSubmissionAssignmentEvents()
        fetchAssignmentDetails()
    }

    // MARK: - Input Actions

    func viewComments(controller: WeakViewController) {
        let view = SubmissionCommentAssembly.makeView(
            courseID: courseID,
            assignmentID: assignmentID,
            attempt: submission?.attempt ?? 0
        )
        router.show(view, from: controller, options: .modal())
    }

    func viewAttempts(controller: WeakViewController) {
        let view = AssignmentAttemptsAssembly.makeView(
            submissions: submissions,
            selectedSubmission: submission
        ) { [weak self] selectedSubmission in
            guard let self, selectedSubmission != submission else {
                return
            }
            hasSubmittedBefore = true
            submission = selectedSubmission
        }
        router.show(view, from: controller, options: .modal(isDismissable: false))
    }

    func showQuizLTI(controller: WeakViewController) {
        let viewController = LTIQuizAssembly.makeView(
            courseID: courseID,
            name: assignment?.name ?? "",
            assignmentID: assignmentID,
            isQuizLTI: assignment?.isQuizLTI,
            externalToolContentID: assignment?.externalToolContentID
        )
        router.show(viewController, from: controller, options: .modal(isDismissable: false))
    }

    func addFile(url: URL) {
        interactor.addFile(url: url)
    }

    func deleteFile(file: File) {
        interactor.cancelFile(file)
    }

    func submit() {
        guard hasSubmittedBefore == false else {
            hasSubmittedBefore = false
            selectedSubmissionIndex = selectedSubmission.index
            return
        }
        showConformationModal(viewModel: makeSubmissionAlertViewModel())
    }

    func showDraftAlert() {
        showConformationModal(viewModel: makeDraftAlertViewModel())
    }

    func markAsDone() {
        isMarkAsDoneLoaderVisible = true
        moduleItemInteractor.markAsDone(
            completed: !isCompletedItem,
            moduleID: moduleID,
            itemID: itemID
        )
        .sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.errorMessage = error.localizedDescription
            }
            self?.isMarkAsDoneLoaderVisible = false
        } receiveValue: { [weak self] _ in
            self?.isCompletedItem.toggle()
        }
        .store(in: &subscriptions)
    }

    // MARK: - Private Functions

    private func fetchAssignmentDetails() {
        Publishers.Zip(interactor.getAssignmentDetails(), interactor.getSubmissions())
            .receive(on: scheduler)
            .sink { [weak self] assignmentDetails, submissions in
                self?.configAssignmentDetails(response: assignmentDetails, submissions: submissions)
            }
            .store(in: &subscriptions)
    }

    private func fetchSubmissions() {
        interactor.getSubmissions()
            .sink { [weak self] submissions in
                guard let self else {
                    return
                }
                self.submissions = submissions
                let latestSubmission = submissions.first?.type ?? .text
                selectedSubmission = hasSubmittedBefore ? latestSubmission : selectedSubmission
                submission = submissions.first
                assignment?.showSubmitButton = submission?.showSubmitButton ?? false
                showConformationModal(viewModel: makeSuccessAlertViewModel(submission: submission))
                hasSubmittedBefore = true
                isLoaderVisible = false
                errorMessage = nil
            }
            .store(in: &subscriptions)
    }

    private func configAssignmentDetails(response: HAssignment, submissions: [HSubmission]) {
        isLoaderVisible = false
        assignment = response
        self.submissions = submissions
        if response.assignmentSubmissionTypes.first == .externalTool {
            selectedSubmission = .externalTool
            fetchExternalURL()
        } else {
            // Didn’t submit before
            isSegmentControlVisible = Set(response.assignmentSubmissionTypes) == Set([.text, .fileUpload])
            let firstSubmission = response.assignmentSubmissionTypes.first ?? .text
            selectedSubmission = isSegmentControlVisible ? .text : firstSubmission
            // In case of resubmission
            hasSubmittedBefore = !response.isUnsubmitted
            let latestSubmission = submissions.first?.type ?? .text
            selectedSubmission = hasSubmittedBefore == true ? latestSubmission : selectedSubmission
            submission = submissions.first
        }
        didLoadAssignment(response.attemptCount, getModuleItem(assignment: response))
    }

    private func fetchExternalURL() {
        let tools = LTITools(
            context: .course(courseID),
            id: assignment?.externalToolContentID,
            launchType: .assessment,
            isQuizLTI: assignment?.isQuizLTI,
            assignmentID: assignmentID
        )

        isLoaderVisible = true
        tools.getSessionlessLaunch { [weak self] value in
            self?.isLoaderVisible = false
            self?.externalURL = value?.url
        }
    }

    private func getModuleItem(assignment: HAssignment) -> HModuleItem {
        HModuleItem(
            id: assignment.id,
            title: assignment.name,
            htmlURL: nil,
            isCompleted: false,
            dueAt: assignment.dueAt,
            type: .assignment(assignment.id),
            isLocked: assignment.isLocked,
            points: assignment.pointsPossible,
            lockedDate: "",
            visibleWhenLocked: true,
            lockedForUser: false,
            lockExplanation: assignment.lockExplanation,
            courseID: assignment.courseID,
            moduleID: "",
            isQuizLTI: assignment.isQuizLTI ?? false
        )
    }

    private func bindSubmissionAssignmentEvents() {
        onTapAssignmentOptions
            .sink { [weak self] in
                self?.isOverlayToolsPresented.toggle()
            }
            .store(in: &subscriptions)

        interactor.attachments
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] files in
                guard let self else {
                    return
                }
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
                    self?.fetchSubmissions()
                    self?.interactor.cancelAllFiles()
                case let .failure(error):
                    self?.isLoaderVisible = false
                    self?.errorMessage = error.localizedDescription
                    self?.interactor.cancelAllFiles()
                }
            }
            .store(in: &subscriptions)
    }

    private func saveTextEntry() {
        textEntryInteractor.save(htmlContent)
    }

    private func fetchDrafts() {
        let lastTextEntryDraft = textEntryInteractor.load()
        htmlContent = lastTextEntryDraft?.text ?? ""
        textEntryTimestamp = lastTextEntryDraft?.dateFormated
        fileUploadTimestamp = attachedFiles.first?.createdAt?.formatted(format: "d/MM, h:mm a")
        lastDraftSavedAt = fileUploadTimestamp
    }

    private func submitTextEntry() {
        interactor.submitTextEntry(with: htmlContent)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.isLoaderVisible = false
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.htmlContent = ""
                self?.textEntryInteractor.delete()
                self?.deleteDraft(isShowToast: false)
                self?.fetchSubmissions()
            }
            .store(in: &subscriptions)
    }

    private func performSubmission() {
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

    private func deleteDraft(isShowToast: Bool = true) {
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
        let draftToastViewModel = ToastViewModel(
            title: AssignmentLocalizedKeys.draftDeletedAlert.title,
            isPresented: isShowToast
        )
        assignmentPreference = .toastViewModel(viewModel: draftToastViewModel)
    }

    private func showConformationModal(viewModel: SubmissionAlertViewModel) {
        assignmentPreference = .confirmation(viewModel: viewModel)
        scheduler.schedule(after: scheduler.now.advanced(by: .seconds(0.2))) {
            viewModel.isPresented = true
        }
    }

    private func makeConfirmationMessage() -> String {
        guard isSegmentControlVisible else {
            return AssignmentLocalizedKeys.confirmationNormalBody.title
        }
        return selectedSubmission == .text
        ? AssignmentLocalizedKeys.submitTextWithUploadFile.title
        : AssignmentLocalizedKeys.submitUploadFileWithText.title
    }

    private func makeSubmissionAlertViewModel() -> SubmissionAlertViewModel {
        SubmissionAlertViewModel(
            title: AssignmentLocalizedKeys.confirmSubmission.title,
            body: makeConfirmationMessage(),
            button: .init(title: AssignmentLocalizedKeys.submitAttempt.title) { [weak self] in
                self?.performSubmission()
            }
        )
    }

    private func makeDraftAlertViewModel() -> SubmissionAlertViewModel {
        SubmissionAlertViewModel(
            title: AssignmentLocalizedKeys.deleteDraftTitle.title,
            body: AssignmentLocalizedKeys.deleteDraftBody.title,
            button: .init(title: AssignmentLocalizedKeys.deleteDraftTitle.title) { [weak self] in
                self?.deleteDraft()
            }
        )
    }

    private func makeSuccessAlertViewModel(submission: HSubmission?) -> SubmissionAlertViewModel {
        SubmissionAlertViewModel(
            title: AssignmentLocalizedKeys.successfullySubmitted.title,
            body: AssignmentLocalizedKeys.successfullySubmittedBody.title,
            type: .success,
            submission: submission,
            button: .init(title: AssignmentLocalizedKeys.viewSubmission.title) {}
        )
    }
}
