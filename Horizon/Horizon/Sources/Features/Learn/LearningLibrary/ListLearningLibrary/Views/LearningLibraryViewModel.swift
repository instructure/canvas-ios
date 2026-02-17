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
import Observation

@Observable
final class LearningLibraryViewModel {
    // MARK: - Inputs / Outputs

    var isErrorVisible: Bool = false

    // MARK: - Outputs

    private(set) var errorMessage = ""
    private(set) var hasLibrary: Bool = false
    private(set) var isLoaderVisible: Bool = true
    var filteredSections: [LearningLibrarySectionModel] { paginator.visibleItems }
    var isSeeMoreVisible: Bool { paginator.isSeeMoreVisible }
    var searchText: String = "" {
        didSet {
            paginator.search(query: searchText)
        }
    }

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()
    private var bookmarkLoadingStates: [String: Bool] = [:]
    private var enrollLoadingStates: [String: Bool] = [:]
    private var allItems: [LearningLibrarySectionModel] = []
    private let paginator = PaginatedDataSource<LearningLibrarySectionModel>(items: [], pageSize: 3)

    // MARK: - Dependencies

    private let router: Router
    private let interactor: LearningLibraryInteractor

    // MARK: - Init

    init(
        router: Router,
        interactor: LearningLibraryInteractor = LearningLibraryInteractorLive()
    ) {
        self.router = router
        self.interactor = interactor
    }

    // MARK: - Input Actions

    func fetchLearningLibrary(ignoreCache: Bool = false, completion: (() -> Void)? = nil) {
        interactor.getLearnLibraryCollections(ignoreCache: ignoreCache)
            .sinkFailureOrValue { [weak self] error in
                self?.isLoaderVisible = false
                self?.showError(with: error.localizedDescription)
                completion?()
            } receiveValue: { [weak self] collections in
                guard let self else { return }
                isLoaderVisible = false
                paginator.setItems(collections, currentPage: paginator.currentPage)
                allItems = collections
                hasLibrary = collections.isNotEmpty
                completion?()
            } .store(in: &subscriptions)
    }

    func refresh() async {
        await withCheckedContinuation { [weak self]  continuation in
            guard let self else {
                continuation.resume()
                return
            }
            fetchLearningLibrary(ignoreCache: true) { continuation.resume() }
        }
    }

    func addBookmark(model: LearningLibraryCardModel) {
        bookmarkLoadingStates[model.id] = true
        interactor.bookmark(id: model.id)
            .sinkFailureOrValue { [weak self] error in
                guard let self else { return }
                self.bookmarkLoadingStates[model.id] = false
                showError(with: error.localizedDescription)
            } receiveValue: { [weak self] collection in
                guard let self else { return }
                self.update(with: collection)
                self.bookmarkLoadingStates[collection.id] = false
            }
            .store(in: &subscriptions)
    }

    func isBookmarkLoading(forItemWithId id: String) -> Bool {
        bookmarkLoadingStates[id] ?? false
    }

    func enroll(model: LearningLibraryCardModel) {
        enrollLoadingStates[model.id] = true
        interactor.enroll(id: model.id)
            .sinkFailureOrValue { [weak self] error in
                guard let self else { return }
                enrollLoadingStates[model.id] = false
                showError(with: error.localizedDescription)
            } receiveValue: { [weak self] collection in
                guard let self else { return }
                self.update(with: collection)
                enrollLoadingStates[collection.id] = false
            }
            .store(in: &subscriptions)
    }

    func isEnrollLoading(forItemWithId id: String) -> Bool {
        enrollLoadingStates[id] ?? false
    }

    func seeMore() {
        paginator.seeMore()
    }

    // MARK: - Navigations

    func navigateToDetails(
        section: LearningLibrarySectionModel,
        viewController: WeakViewController
    ) {
        router.show(
            LearningLibraryAssembly.makeViewController(pageType: .details(id: section.id, name: section.name)),
            from: viewController
        )
    }

    func navigateToItem(model: LearningLibraryCardModel, viewController: WeakViewController) {
        switch model.itemType {
        case .course:
            guard let courseEnrollmentId = model.courseEnrollmentId else {
                return
            }
            router.show(
                CourseDetailsAssembly.makeCourseDetailsViewController(
                    courseID: model.itemId,
                    enrollmentID: courseEnrollmentId
                ),
                from: viewController
            )

        case .program:
            router.show(
                ProgramDetailsAssembly.makeViewController(programID: ""),
                from: viewController
            )
        default:
            print("Tapped")
        }

    }

    func navigateToBookmarks(viewController: WeakViewController) {
        router.show(
            LearningLibraryAssembly.makeViewController(pageType: .bookmarks),
            from: viewController
        )
    }

    func navigateToCompleted(viewController: WeakViewController) {
        router.show(
            LearningLibraryAssembly.makeViewController(pageType: .completed),
            from: viewController
        )
    }

    // MARK: - Private Functions

    private func update(with collection: LearningLibraryCardModel) {
        if let index = self.allItems.firstIndex(where: { $0.id == collection.libraryId }) {
            allItems[index].update(item: collection)
        }

        if let visibleIndex = self.paginator.visibleItems.firstIndex(where: { $0.id == collection.libraryId }) {
            if let index = self.paginator.visibleItems[visibleIndex].items.firstIndex(where: { $0.id == collection.id }) {
                paginator.visibleItems[visibleIndex].items[index] = collection
            }
        }
    }

    private func showError(with message: String) {
        errorMessage = message
        isErrorVisible = true
    }
}
