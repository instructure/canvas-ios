//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Foundation

@Observable
final class ManageOfflineContentViewModel {
    // MARK: - Outputs

    private(set) var courses: [OfflineCourseItem] = []
    private(set) var isLoaderVisible: Bool = true
    private(set) var errorMessage = ""
    var selectAllState: OfflineCheckboxState {
        let allChecked = courses.allSatisfy { $0.selectionState == .checked }
        let noneChecked = courses.allSatisfy { $0.selectionState == .unchecked }
        if allChecked { return .checked }
        if noneChecked { return .unchecked }
        return .partial
    }

    var selectedSizeCourse: String {
        let selectedCourses = courses.filter({ $0.selectionState == .checked || $0.selectionState == .partial })
        let size = selectedCourses.reduce(0) { $0 + $1.sizeToDownload }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }

    var isRemoveButtonEnabled: Bool {
        session.horizonOfflineSyncItems.isNotEmpty
    }

    // MARK: - Inputs / Outputs

    var isErrorVisible = false

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let interactor: ManageOfflineContentInteractor
    private let router: Router
    private let session: SessionDefaults

    // MARK: - Init

    init(
        interactor: ManageOfflineContentInteractor,
        router: Router,
        session: SessionDefaults
    ) {
        self.interactor = interactor
        self.router = router
        self.session = session
        fetchCourses(ignoreCache: false)
    }

    // MARK: - Private Functions

    private func fetchCourses(
        ignoreCache: Bool,
        completion: (() -> Void)? = nil
    ) {
        interactor.getCourses(ignoreCache: ignoreCache)
            .sinkFailureOrValue { [weak self] error in
                self?.isLoaderVisible = false
                self?.errorMessage = error.localizedDescription
                self?.isErrorVisible = true
                completion?()
            } receiveValue: { [weak self] items in
                self?.courses = items
                self?.isLoaderVisible = false
                completion?()
            }
            .store(in: &subscriptions)
    }

    // MARK: - Input Actions

    @MainActor
    func refresh() async {
        await withCheckedContinuation { continuation in
            fetchCourses(ignoreCache: true) {
                continuation.resume()
            }
        }
    }

    func toggleSelectAll() {
        let shouldSelectAll = selectAllState != .checked
        courses = courses.map { course in
            var updated = course
            if course.subItems.isEmpty {
                updated.isSelected = shouldSelectAll
            } else {
                updated.subItems = course.subItems.map { item in
                    var updatedItem = item
                    updatedItem.isSelected = shouldSelectAll
                    return updatedItem
                }
            }
            return updated
        }
    }

    func toggleExpand(_ courseID: String) {
        guard let index = courses.firstIndex(where: { $0.id == courseID }) else { return }
        var updated = courses[index]
        updated.isExpanded.toggle()
        courses[index] = updated
    }

    func toggleCourse(_ course: OfflineCourseItem) {
        guard let index = courses.firstIndex(where: { $0.id == course.id }) else { return }
        let shouldSelect = courses[index].selectionState != .checked
        if !courses[index].hasSubItems {
            courses[index].isSelected = shouldSelect
        } else {
            courses[index].subItems = courses[index].subItems.map { item in
                var updated = item
                updated.isSelected = shouldSelect
                return updated
            }
        }
    }

    func toggleSubItem(courseID: String, subItemID: String) {
        guard let courseIndex = courses.firstIndex(where: { $0.id == courseID }),
              let itemIndex = courses[courseIndex].subItems.firstIndex(where: { $0.id == subItemID })
        else { return }
        var updatedCourse = courses[courseIndex]
        updatedCourse.subItems[itemIndex].isSelected.toggle()
        courses[courseIndex] = updatedCourse
    }

    func pop(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func presentConfirmation(type: OfflineConfirmationView.ConfirmationType, viewController: WeakViewController) {
        let view = OfflineConfirmationAssembly.makeView(type: type) {

        }
        router.show(view, from: viewController, options: .modal(.fullScreen))
    }
}
