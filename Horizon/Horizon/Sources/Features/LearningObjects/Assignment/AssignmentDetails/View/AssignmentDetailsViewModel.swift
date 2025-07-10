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
            if isTyping {
                saveTextEntry()
                lastDraftSavedAt = dependency.textEntryInteractor.load()?.dateFormated
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
    private(set) var submissionProperties: SubmissionProperties?
    private(set) var shouldShowViewAttempts = false
    var isTyping = false
    var assignmentPreference: AssignmentPreferenceKeyType?
    var isSubmitButtonHidden: Bool {
        assignment?.submissionTypes.contains(.none) == true && assignment?.submissionTypes.count == 1
    }

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()
    private var textEntryTimestamp: String?
    private var fileUploadTimestamp: String?
    private var submissions: [HSubmission] = []
    private var submissionComments: [SubmissionComment] = []
    var selectedSubmissionIndex: Int = 0 {
        didSet {
            selectedSubmission = AssignmentSubmissionType(index: selectedSubmissionIndex)
            setLastDraftSavedAt()
        }
    }

    var hasSubmittedBefore: Bool = false {
        didSet {
            submitButtonTitle = hasSubmittedBefore
            ? AssignmentLocalizedKeys.newAttempt.title
            : AssignmentLocalizedKeys.submitAssignment.title
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

    var dependency: Dependency

    // MARK: - Init

    init(dependency: Dependency) {
        self.dependency = dependency
        bindSubmissionAssignmentEvents()
        fetchAssignmentDetails()
    }

    // MARK: - Input Actions

    func viewComments(controller: WeakViewController) {
        let view = SubmissionCommentAssembly.makeView(
            courseID: dependency.courseID,
            assignmentID: dependency.assignmentID,
            attempt: submission?.attempt ?? 0
        )
        dependency.router.show(view, from: controller, options: .modal(isDismissable: false))
    }

    func viewAttempts(controller: WeakViewController) {
        let view = AssignmentAttemptsAssembly.makeView(
            submissions: submissions,
            selectedSubmission: submission
        ) { [weak self] selectedSubmission in
            guard let self, selectedSubmission != submission else { return }
            hasSubmittedBefore = true
            submission = selectedSubmission
            shouldShowViewAttempts = selectedSubmission != submissions.first
            submissionProperties?.hasUnreadComments = submissionComments.hasUnreadComments(
                for: selectedSubmission?.attempt
            )
            dependency.didLoadAssignment(submissionProperties)
        }
        dependency.router.show(view, from: controller, options: .modal(isDismissable: false))
    }

    func showQuizLTI(controller: WeakViewController) {
        let viewController = LTIQuizAssembly.makeView(
            courseID: dependency.courseID,
            moduleID: dependency.moduleID,
            itemID: dependency.itemID,
            name: assignment?.name ?? "",
            assignmentID: dependency.assignmentID,
            isQuizLTI: assignment?.isQuizLTI,
            externalToolContentID: assignment?.externalToolContentID
        )
        dependency.router.show(viewController, from: controller, options: .modal(isDismissable: false))
    }

    func submit() {
        guard hasSubmittedBefore == false else {
            hasSubmittedBefore = false
            selectedSubmissionIndex = selectedSubmission.index
            return
        }
        showConfirmationModal(
            viewModel: AssignmentConfirmationMessagesAssembly.makeSubmissionAlertViewModel(
                isSegmentControlVisible: isSegmentControlVisible,
                isTextSubmission: selectedSubmission == .text
            ) { [weak self] in self?.performSubmission() })
    }

    func showDraftAlert() {
        showConfirmationModal(
            viewModel: AssignmentConfirmationMessagesAssembly
                .makeDraftAlertViewModel { [weak self] in self?.deleteDraft() })
    }

    func markAsDone() {
        isMarkAsDoneLoaderVisible = true
        dependency.moduleItemInteractor.markAsDone(
            completed: !dependency.isCompletedItem,
            moduleID: dependency.moduleID,
            itemID: dependency.itemID
        )
        .sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.errorMessage = error.localizedDescription
            }
            self?.isMarkAsDoneLoaderVisible = false
        } receiveValue: { [weak self] _ in
            self?.dependency.isCompletedItem.toggle()
        }
        .store(in: &subscriptions)
    }

    func refresh() async {
        await withCheckedContinuation { continuation in
            fetchAssignmentDetails(ignoreCache: true) {
                continuation.resume()
            }
        }
    }

    // MARK: - Private Functions

    private func fetchAssignmentDetails(
        ignoreCache: Bool = false,
        completionHandler: (() -> Void)? = nil
    ) {
        Publishers.Zip3(
            dependency.interactor.getAssignmentDetails(ignoreCache: ignoreCache),
            dependency.interactor.getSubmissions(ignoreCache: ignoreCache),
            dependency.commentInteractor.getComments(
                assignmentID: dependency.assignmentID,
                ignoreCache: ignoreCache
            )
        )
        .receive(on: dependency.scheduler)
        .sinkFailureOrValue(
            receiveFailure: { [weak self] error in
                self?.isLoaderVisible = false
                self?.errorMessage = error.localizedDescription
                completionHandler?()
            },
            receiveValue: { [weak self] result in
                let (assignmentDetails, submissions, comments) = result
                self?.updateAssignmentDetails(
                    response: assignmentDetails,
                    submissions: submissions,
                    submissionComments: comments
                )
                completionHandler?()
            }
        )
        .store(in: &subscriptions)
    }

    private func updateAssignmentDetails(
        response: HAssignment,
        submissions: [HSubmission],
        submissionComments: [SubmissionComment]
    ) {
        isLoaderVisible = false
        assignment = response
        self.submissions = submissions
        self.submissionComments = submissionComments

        // Handle External Tool submission type
        if response.assignmentSubmissionTypes.first == .externalTool {
            selectedSubmission = .externalTool
            fetchExternalURL()
        } else {
            // Determine if segmented control is needed
            let submissionTypes = Set(response.assignmentSubmissionTypes)
            isSegmentControlVisible = submissionTypes == Set([.text, .fileUpload])
            // Didn’t submit before
            isSegmentControlVisible = Set(response.assignmentSubmissionTypes) == Set([.text, .fileUpload])
            let firstSubmission = response.assignmentSubmissionTypes.first ?? .text
            selectedSubmission = isSegmentControlVisible ? .text : firstSubmission
            // In case of resubmission
            hasSubmittedBefore = !response.isUnsubmitted
            let latestSubmissionType = submissions.first?.type ?? .text
            selectedSubmission = hasSubmittedBefore == true ? latestSubmissionType : selectedSubmission
            submission = submissions.first
        }

        // Build submission properties
        submissionProperties = .init(
            attemptCount: response.attemptCount,
            moduleItem: response.toModuleItem(),
            hasUnreadComments: submissionComments.hasUnreadComments(for: submission?.attempt)
        )
        dependency.didLoadAssignment(submissionProperties)
    }

    private func fetchExternalURL() {
        let tools = LTITools(
            context: .course(dependency.courseID),
            id: assignment?.externalToolContentID,
            launchType: .assessment,
            isQuizLTI: assignment?.isQuizLTI,
            assignmentID: dependency.assignmentID,
            env: dependency.environment
        )

        isLoaderVisible = true
        tools.getSessionlessLaunch { [weak self] value in
            self?.isLoaderVisible = false
            self?.externalURL = value?.url
        }
    }

    private func fetchSubmissions() {
        dependency.interactor.getSubmissions(ignoreCache: true)
            .sinkFailureOrValue(receiveFailure: { [weak self] error in
                self?.isLoaderVisible = false
                self?.errorMessage = error.localizedDescription

            }, receiveValue: { [weak self] submissions in
                guard let self else {
                    return
                }
                self.submissions = submissions
                let latestSubmission = submissions.first?.type ?? .text
                selectedSubmission = hasSubmittedBefore ? latestSubmission : selectedSubmission
                submission = submissions.first
                assignment?.showSubmitButton = submission?.showSubmitButton ?? false
                showConfirmationModal(
                    viewModel: AssignmentConfirmationMessagesAssembly.makeSuccessAlertViewModel(
                        submission: submission
                    )
                )
                hasSubmittedBefore = true
                isLoaderVisible = false
                errorMessage = nil
            })
            .store(in: &subscriptions)
    }

    private func bindSubmissionAssignmentEvents() {
        dependency.onTapAssignmentOptions
            .sink { [weak self] in
                self?.isOverlayToolsPresented.toggle()
            }
            .store(in: &subscriptions)

        dependency.interactor.attachments
            .removeDuplicates()
            .receive(on: dependency.scheduler)
            .sink { [weak self] files in
                guard let self else {
                    return
                }
                attachedFiles = files
                fetchDrafts()
            }
            .store(in: &subscriptions)

        dependency.interactor
            .didUploadFiles
            .receive(on: dependency.scheduler)
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.fetchSubmissions()
                case let .failure(error):
                    self?.isLoaderVisible = false
                    self?.errorMessage = error.localizedDescription
                    self?.dependency.interactor.cancelAllFiles()
                }
            }
            .store(in: &subscriptions)
    }

    private func submitTextEntry() {
        dependency.interactor.submitTextEntry(
            with: htmlContent,
            moduleID: dependency.moduleID,
            moduleItemID: dependency.itemID
        )
        .sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.isLoaderVisible = false
                self?.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] _ in
            self?.htmlContent = ""
            self?.dependency.textEntryInteractor.delete()
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
            dependency.interactor.uploadFiles()
        default:
            break
        }
    }

    private func showConfirmationModal(viewModel: SubmissionAlertViewModel) {
        assignmentPreference = .confirmation(viewModel: viewModel)
        dependency.scheduler.schedule(after: dependency.scheduler.now.advanced(by: .seconds(0.2))) {
            viewModel.isPresented = true
        }
    }

    // MARK: - Local Storage

    private func saveTextEntry() {
        dependency.textEntryInteractor.save(htmlContent)
    }

    private func fetchDrafts() {
        let lastTextEntryDraft = dependency.textEntryInteractor.load()
        htmlContent = lastTextEntryDraft?.text ?? ""
        textEntryTimestamp = lastTextEntryDraft?.dateFormated
        fileUploadTimestamp = attachedFiles.first?.createdAt?.formatted(format: "d/MM, h:mm a")
        lastDraftSavedAt = fileUploadTimestamp
    }

    private func deleteDraft(isShowToast: Bool = true) {
        switch selectedSubmission {
        case .text:
            dependency.textEntryInteractor.delete()
            textEntryTimestamp = nil
            lastDraftSavedAt = nil
            htmlContent = ""
        case .fileUpload:
            dependency.interactor.cancelAllFiles()
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

    func addFile(url: URL) {
        dependency.interactor.addFile(url: url)
    }

    func deleteFile(file: File) {
        dependency.interactor.cancelFile(file)
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
}

// MARK: - Dependency

extension AssignmentDetailsViewModel {
    struct Dependency {
        let environment: AppEnvironment = .shared
        let interactor: AssignmentInteractor
        let moduleItemInteractor: ModuleItemSequenceInteractor
        let textEntryInteractor: AssignmentTextEntryInteractor
        let commentInteractor: SubmissionCommentInteractor
        let isMarkedAsDone: Bool
        var isCompletedItem: Bool
        let moduleID: String
        let itemID: String
        let router: Router
        let courseID: String
        let assignmentID: String
        let onTapAssignmentOptions: PassthroughSubject<Void, Never>
        let scheduler: AnySchedulerOf<DispatchQueue>
        let didLoadAssignment: (SubmissionProperties?) -> Void
    }
}

private extension Array where Element == SubmissionComment {
    func hasUnreadComments(for attempt: Int?) -> Bool {
        return self.contains { comment in
            (comment.attempt == attempt || attempt == nil) && !comment.isRead
        }
    }
}

private extension HAssignment {
    func toModuleItem() -> HModuleItem {
        HModuleItem(
            id: id,
            title: name,
            htmlURL: nil,
            isCompleted: false,
            dueAt: dueAt,
            type: .assignment(id),
            isLocked: isLocked,
            points: pointsPossible,
            lockedDate: nil,
            visibleWhenLocked: true,
            lockedForUser: false,
            lockExplanation: lockExplanation,
            courseID: courseID,
            moduleID: "",
            isQuizLTI: isQuizLTI ?? false
        )
    }
}
