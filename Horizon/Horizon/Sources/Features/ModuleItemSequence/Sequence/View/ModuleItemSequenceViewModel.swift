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

import Combine
import Core
import Foundation
import Observation

@Observable
final class ModuleItemSequenceViewModel {
    typealias AssetType = GetModuleItemSequenceRequest.AssetType

    // MARK: - Output

    private(set) var viewState: ModuleItemSequenceViewState?
    private(set) var assignmentDetailsViewModel: AssignmentDetailsViewModel?
    private(set) var isNextButtonEnabled: Bool = false
    private(set) var isPreviousButtonEnabled: Bool = false
    private(set) var isLoaderVisible: Bool = false
    private(set) var errorMessage: String?
    private(set) var courseName = ""
    private(set) var moduleItem: HModuleItem?
    private(set) var assignmentAttemptCount: String?
    private var isAssignmentOptionsButtonVisible: Bool = false
    var estimatedTime: String? {
        guard let moduleItem else {
            return nil
        }
        let items = course?.modules.first(where: { $0.id == moduleItem.moduleID })?.items
        return items?.first(where: { $0.id == moduleItem.id })?.estimatedDurationFormatted
    }

    var visibleButtons: [ModuleNavBarUtilityButtons] {
        var buttons: [ModuleNavBarUtilityButtons] = [.chatBot(navigateToTutor)]
        if isAssignmentOptionsButtonVisible, moduleItem?.isQuizLTI == false {
          buttons.append(.assignmentMoreOptions(assignmentOptionsTapped, hasBadge: hasUnreadComments))
        } else if moduleItem?.type?.assetType == .page && isNotebookDisabled == false {
          buttons.append(.notebook(navigateToNotebook))
        }
        return buttons
    }

    // MARK: - Input / Output

    var offsetX: CGFloat = 0
    var isShowErrorAlert: Bool = false
    var onTapAssignmentOptions = PassthroughSubject<Void, Never>()
    var didLoadAssignment: (SubmissionProperties?) -> Void = { _ in }
    private var isAssignmentAvailableInItemSequence = true

    // MARK: - Private Properties

    private var moduleID: String?
    private var itemID: String?
    private var subscriptions = Set<AnyCancellable>()
    private var sequence: HModuleItemSequence?
    private var course: HCourse?
    var hasUnreadComments: Bool = false

    // MARK: - Dependencies
    private var error: String?
    private let moduleItemInteractor: ModuleItemSequenceInteractor
    private let moduleItemStateInteractor: ModuleItemStateInteractor
    private let router: Router
    private var assetType: AssetType
    private let assetID: String
    private let courseID: String
    private let isNotebookDisabled: Bool
    // Need to save the completion state for the module items without observation
    private var unobservedCourse: HCourse?
    private var firstModuleItem: HModuleItem?

    // MARK: - Init

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(
        moduleItemInteractor: ModuleItemSequenceInteractor,
        moduleItemStateInteractor: ModuleItemStateInteractor,
        router: Router,
        assetType: AssetType,
        firstModuleItem: HModuleItem? = nil,
        assetID: String,
        courseID: String,
        isNotebookDisabled: Bool = false
    ) {
        self.moduleItemInteractor = moduleItemInteractor
        self.moduleItemStateInteractor = moduleItemStateInteractor
        self.router = router
        self.assetType = assetType
        self.assetID = assetID
        self.courseID = courseID
        self.isNotebookDisabled = isNotebookDisabled
        self.firstModuleItem = firstModuleItem

        fetchModuleItemSequence(assetId: assetID)

        moduleItemInteractor.getCourse(ignoreCache: false)
            .sink { [weak self] course in
                self?.courseName = course.name
                self?.course = course
                if self?.unobservedCourse == nil {
                    self?.unobservedCourse = course
                }
            }
            .store(in: &subscriptions)

        didLoadAssignment = { [weak self] model in
            if model?.moduleItem.isQuizLTI == false {
                self?.assignmentAttemptCount = model?.attemptCount
            }
            if self?.isAssignmentAvailableInItemSequence == false {
                self?.moduleItem = model?.moduleItem
            }
            self?.hasUnreadComments = model?.hasUnreadComments ?? false
        }

        NotificationCenter.default.addObserver(
            forName: .moduleItemRequirementCompleted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refershModuleItem()
        }
    }

    // MARK: - Input Functions

    func pop(from controller: WeakViewController) {
        router.pop(from: controller)
    }

    func navigateToCourseProgress(from controller: WeakViewController) {
        guard let course else {
            return
        }
        assignmentAttemptCount = nil
        let viewController = CourseProgressAssembly.makeView(
            course: course,
            currentModuleItem: moduleItem
        ) { [weak self] selectedModuleItem in
            guard selectedModuleItem != self?.moduleItem else {
                return
            }
            self?.itemID = selectedModuleItem?.id
            self?.moduleID = selectedModuleItem?.moduleID
            self?.moduleItem = selectedModuleItem
            self?.fetchModuleItemSequence(assetId: selectedModuleItem?.id ?? "")
        }
        router.show(viewController, from: controller, options: .modal(isDismissable: false))
    }

    // MARK: - Private Functions

    private func assignmentOptionsTapped(_: WeakViewController) {
        onTapAssignmentOptions.send()
    }

    private func fetchModuleItemSequence(
        assetId: String,
        ignoreCache: Bool = false
    ) {
        isLoaderVisible = true
        moduleItemInteractor.fetchModuleItems(
            assetType: assetType,
            assetID: assetId,
            moduleID: moduleID,
            itemID: itemID,
            ignoreCache: false
        )
        .sink { [weak self] result in
            self?.isLoaderVisible = false
            if result.0?.current == nil {
                self?.errorMessage = String(localized: "Sorry, we were unable to find this item.", bundle: .horizon)
                self?.isShowErrorAlert = true
                return
            }
            self?.assetType = .moduleItem
            let firstSequence = result.0
            self?.sequence = firstSequence
            self?.isNextButtonEnabled = firstSequence?.next != nil
            self?.isPreviousButtonEnabled = firstSequence?.previous != nil
            self?.moduleItem = result.1
            self?.updateModuleItemDetails()
        }
        .store(in: &subscriptions)
    }

    private func navigateToNotebook(viewController: WeakViewController) {
        guard case .page(let pageUrl) = moduleItem?.type else {
            return
        }
        router.route(to: "/notebook?courseID=\(self.courseID)&pageURL=\(pageUrl)", from: viewController)
    }

    private func navigateToTutor(viewController: WeakViewController) {
        guard let courseId = moduleItem?.courseID else {
            return
        }

        var fileId: String?
        var pageUrl: String?

        switch moduleItem?.type {
        case .file(let id):
                fileId = id
        case .page(let url):
                pageUrl = url
        default:
            break
        }

        let params = [
            "courseId": courseId,
            "pageUrl": pageUrl,
            "fileId": fileId
        ].map { key, value in
            guard let value = value else { return nil }
            return "\(key)=\(value)"
        }.compactMap { $0 }.joined(separator: "&")
        router.route(to: "/assistant?\(params)", from: viewController, options: .modal())
    }

    private func updateModuleItemDetails() {
        moduleID = moduleItem?.moduleID
        itemID = moduleItem?.id
        var currentState = getCurrentState(item: moduleItem)

        if currentState == nil {
            currentState = .error
        }
        viewState = currentState
        offsetX = 0
    }

    private func getAssignmentModuleItem() -> ModuleItemSequenceViewState {
        .assignment(
            courseID: courseID,
            assignmentID: assetID,
            isMarkedAsDone: false,
            isCompletedItem: false,
            moduleID: "", // No needed for  moduleID & itemID in this case
            itemID: ""
        )
    }

    private func getCurrentState(item: HModuleItem?) -> ModuleItemSequenceViewState? {
        var state = moduleItemStateInteractor.getModuleItemState(
            sequence: sequence,
            item: item,
            moduleID: moduleID,
            itemID: itemID
        )
        markAsViewed()
        isAssignmentOptionsButtonVisible = state?.isAssignment ?? false
        /// In some cases, the module sequence API returns an empty response for assignment type only.
        if state?.isExternalURL == true, item == nil {
           let assignemtModuleItem = getAssignmentModuleItem()
             if assignemtModuleItem.isAssignment {
                isAssignmentAvailableInItemSequence = false
                 state = assignemtModuleItem
            }
        }
        if case let .assignment(courseID, assignmentID, isMarkedAsDone, isCompletedItem, moduleID, itemID) = state {
            assignmentDetailsViewModel = AssignmentDetailsAssembly.makeViewModel(
                courseID: courseID,
                assignmentID: assignmentID,
                isMarkedAsDone: isMarkedAsDone,
                isCompletedItem: isCompletedItem,
                moduleID: moduleID,
                itemID: itemID,
                onTapAssignmentOptions: onTapAssignmentOptions,
                didLoadAssignment: didLoadAssignment
            )
        }
        return state
    }

    private func markAsViewed() {
        guard let moduleID, let itemID, let moduleItem else {
            return
        }
        guard moduleItem.completionRequirementType == .must_view,
              isModuleItemCompleted(moduleId: moduleID, itemId: itemID) == false,
              moduleItem.lockedForUser == false else {
            return
        }
        unobservedCourse = course
        moduleItemInteractor
            .markAsViewed(moduleID: moduleID, itemID: itemID)
            .sink()
            .store(in: &subscriptions)
    }

    private func isModuleItemCompleted(moduleId: String, itemId: String) -> Bool? {
        if itemID == firstModuleItem?.id {
            let isCompleted = firstModuleItem?.isCompleted
            firstModuleItem = nil
            return isCompleted
        } else {
            return getModuleItem(moduleId: moduleId, itemId: itemId)?.isCompleted
        }
    }

    private func getModuleItem(moduleId: String, itemId: String) -> HModuleItem? {
        guard let selectedModule = unobservedCourse?.modules.first(where: { $0.id == moduleId }) else {
            return nil
        }
        return selectedModule.items.first(where: { $0.id == itemId })
    }

    func retry() {
        fetchModuleItemSequence(
            assetId: moduleItem?.id ?? assetID,
            ignoreCache: true
        )
    }

    func goNext() {
        guard let next = sequence?.next else { return }
        moduleID = next.moduleID
        itemID = next.id
        update(item: next)
    }

    func goPrevious() {
        guard let previous = sequence?.previous else { return }
        moduleID = previous.moduleID
        itemID = previous.id
        update(item: previous)
    }

    private func update(item: HModuleItemSequenceNode) {
        assignmentAttemptCount = nil
        moduleID = item.moduleID
        itemID = item.id
        guard let itemID else {
            return
        }
        fetchModuleItemSequence(assetId: itemID)
    }

    private func refershModuleItem() {
        guard let next = sequence?.next,
              let moduleItem = getModuleItem(moduleId: next.moduleID, itemId: next.id) else {
            return
        }

        /// If the next module item is `must_view` and locked, fetch the course to unlock it.
        if moduleItem.completionRequirementType == .must_view {
            guard moduleItem.isLocked else { return }

            moduleItemInteractor.getCourse(ignoreCache: true)
                .sink { [weak self] course in
                    self?.course = course
                }
                .store(in: &subscriptions)
        } else {
            /// Otherwise, fetch module items normally.
            moduleItemInteractor.fetchModuleItems(
                assetType: assetType,
                assetID: next.id,
                moduleID: next.moduleID,
                itemID: next.id,
                ignoreCache: true
            )
            .sink()
            .store(in: &subscriptions)
        }
    }
}
