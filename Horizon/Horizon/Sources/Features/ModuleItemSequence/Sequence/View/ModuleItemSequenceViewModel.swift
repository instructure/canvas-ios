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
import Observation

@Observable
final class ModuleItemSequenceViewModel {
    typealias AssetType = GetModuleItemSequenceRequest.AssetType
    // MARK: - Output

    private(set) var viewState: ModuleItemSequenceViewState?
    private(set) var isNextButtonEnabled: Bool = false
    private(set) var isPreviousButtonEnabled: Bool = false
    private(set) var isLoaderVisible: Bool = false
    private(set) var errorMessage = ""
    private(set) var courseName = ""
    private(set) var moduleItem: HModuleItem?
    private(set) var assignmentAttemptCount: String?
    private(set) var isAssignmentOptionsButtonVisible: Bool = false
    var estimatedTime: String? {
        guard let moduleItem else {
            return nil
        }
        let items = course?.modules.first(where: { $0.id == moduleItem.moduleID })?.items
        return items?.first(where: { $0.id == moduleItem.id})?.estimatedDurationFormatted
    }

    // MARK: - Input / Output

    var offsetX: CGFloat = 0
    var isShowErrorAlert: Bool = false
    var onTapAssignmentOptions = PassthroughSubject<Void, Never>()
    var didLoadAssignment: (String?, HModuleItem) -> Void = { _, _ in }
    private var isAssignmentAvailableInItemSequence = true

    // MARK: - Private Properties
    private var moduleID: String?
    private var itemID: String?
    private var subscriptions = Set<AnyCancellable>()
    private var sequence: HModuleItemSequence?
    private var course: HCourse?

    // MARK: - Dependencies

    private let moduleItemInteractor: ModuleItemSequenceInteractor
    private let moduleItemStateInteractor: ModuleItemStateInteractor
    private let router: Router
    private let assetType: AssetType
    private let assetID: String
    private let courseID: String

    // MARK: - Init

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(
        moduleItemInteractor: ModuleItemSequenceInteractor,
        moduleItemStateInteractor: ModuleItemStateInteractor,
        router: Router,
        assetType: AssetType,
        assetID: String,
        courseID: String
    ) {
        self.moduleItemInteractor = moduleItemInteractor
        self.moduleItemStateInteractor = moduleItemStateInteractor
        self.router = router
        self.assetType = assetType
        self.assetID = assetID
        self.courseID = courseID

        fetchModuleItemSequence(assetId: assetID)

        moduleItemInteractor.getCourse()
            .sink { [weak self] course in
                self?.courseName = course.name
                self?.course = course
            }
            .store(in: &subscriptions)

        didLoadAssignment = { [weak self] count, moduleItem in
            self?.assignmentAttemptCount = count
            if self?.isAssignmentAvailableInItemSequence == false {
                self?.moduleItem = moduleItem
            }
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

    private func fetchModuleItemSequence(assetId: String) {
        isLoaderVisible = true
        moduleItemInteractor.fetchModuleItems(
            assetId: assetId,
            moduleID: moduleID,
            itemID: itemID
        )
        .sink { [weak self] result in
            self?.isLoaderVisible = false
            let firstSequence = result.0
            self?.sequence = firstSequence
            self?.isNextButtonEnabled = firstSequence?.next != nil
            self?.isPreviousButtonEnabled = firstSequence?.previous != nil
            self?.moduleItem = result.1
            self?.updateModuleItemDetails()
        }
        .store(in: &subscriptions)
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
        if state?.isModuleItem == true {
            markAsViewed()
        }
        isAssignmentOptionsButtonVisible = state?.isAssignment ?? false
        /// In some cases, the module sequence API returns an empty response for assignment type only.
        if state?.isExternalURL == true, assetType == .assignment {
            state = getAssignmentModuleItem()
            isAssignmentAvailableInItemSequence = false
        }
        return state
    }

    private func markAsViewed() {
        guard let moduleID, let itemID, let moduleItem  else {
            return
        }

        NotificationCenter.default.post(name: .moduleItemViewDidLoad, object: nil, userInfo: [
            "moduleID": moduleID,
            "itemID": itemID
        ])

        guard moduleItem.completionRequirementType == .must_view,
              moduleItem.isCompleted == false,
              moduleItem.lockedForUser == false else {
            return
        }
        moduleItemInteractor
            .markAsViewed(moduleID: moduleID, itemID: itemID)
            .sink()
            .store(in: &subscriptions)
    }

    func markAsDone() {
        guard let moduleID, let itemID else {
            return
        }
        isLoaderVisible = true
        moduleItemInteractor.markAsDone(
            completed: moduleItem?.isCompleted == false,
            moduleID: moduleID,
            itemID: itemID
        )
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.isShowErrorAlert = true
                self?.errorMessage = error.localizedDescription
            }
            self?.isLoaderVisible = false
        } receiveValue: { _ in}
            .store(in: &subscriptions)
    }

    func retry() {
        fetchModuleItemSequence(assetId: moduleItem?.id ?? assetID)
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
}
