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

import Combine
import Core
import Foundation
import Observation

@Observable
final class LearningLibraryDetailsViewModel {
    // MARK: - Outputs

    private(set) var hasItems = false
    private(set) var isLoaderVisible: Bool = true
    var selectedLearningObject = LearningLibraryObjectType.firstOption { didSet { filter() }}
    var selectedLearningLibrary = LearningLibraryFilter.firstOption { didSet { filter() } }
    var searchText: String = "" { didSet { filter() } }
    var filteredItems: [LearningLibraryCardModel] { paginator.visibleItems }
    var isSeeMoreVisible: Bool { paginator.isSeeMoreVisible }

    // MARK: - Private variables

    private var bookmarkLoadingStates: [String: Bool] = [:]
    private var enrollLoadingStates: [String: Bool] = [:]
    private var allItems: [LearningLibraryCardModel] = []
    private let paginator = PaginatedDataSource<LearningLibraryCardModel>(items: [], pageSize: 6)
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    var model: LearningLibrarySectionModel = .init(id: "", name: "", items: [])
    private let router: Router
    private let interactor: LearningLibraryInteractor
    let pageType: PageType

    // MARK: - Init

    init(
        interactor: LearningLibraryInteractor,
        router: Router,
        pageType: PageType
    ) {
        self.pageType = pageType
        self.router = router
        self.interactor = interactor
        fetchLearningLibraryItems()
    }

    // MARK: - Input Actions

    func fetchLearningLibraryItems(
        ignoreCache: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        interactor.getLearnLibraryItems(ignoreCache: ignoreCache)
            .sinkFailureOrValue { [weak self] _ in
                self?.isLoaderVisible = false
                completion?()
            } receiveValue: { [weak self] items in
                self?.isLoaderVisible = false
                self?.configResponse(items: items)
                self?.filter()
                completion?()
            }
            .store(in: &subscriptions)
    }

    func refresh() async {
        await withCheckedContinuation { [weak self]  continuation in
            guard let self else {
                continuation.resume()
                return
            }
            fetchLearningLibraryItems(ignoreCache: true) { continuation.resume() }
        }
    }

    func filter() {
        var items = allItems
        /// -1 refers to `All Items` have been selected for `LearningLibraryObjectType`
        if selectedLearningObject.id != "-1",
           let objectType = LearningLibraryObjectType(rawValue: selectedLearningObject.id) {
            items = items.filter { $0.itemType == objectType }
        }

        if let filterType = LearningLibraryFilter(rawValue: selectedLearningLibrary.id) {
            switch filterType {
            case .all:
                break
            case .completed:
                items = items.filter { $0.isCompleted }
            case .bookmarked:
                items = items.filter { $0.isBookmarked }
            }
        }

        if searchText.trimmedEmptyLines.isNotEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        paginator.setItems(items)
    }

    func seeMore() {
        paginator.seeMore()
    }

    func pop(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func addBookmark(model: LearningLibraryCardModel) {
        bookmarkLoadingStates[model.id] = true
        interactor.bookmark(id: model.id)
            .sinkFailureOrValue { error in
                print(error)
            } receiveValue: { [weak self] item in
                guard let self else { return }

                configItem(item: item)
                bookmarkLoadingStates[model.id] = false
            }
            .store(in: &subscriptions)
    }

    func isBookmarkLoading(forItemWithId id: String) -> Bool {
        bookmarkLoadingStates[id] ?? false
    }

    func enroll(model: LearningLibraryCardModel) {
        enrollLoadingStates[model.id] = true
        interactor.enroll(id: model.id)
            .sinkFailureOrValue { error in
                print(error)
            } receiveValue: { [weak self] item in
                guard let self else { return }
                configItem(item: item)
                enrollLoadingStates[model.id] = false
            }
            .store(in: &subscriptions)
    }

    func isEnrollLoading(forItemWithId id: String) -> Bool {
        enrollLoadingStates[id] ?? false
    }

    func navigateToDetails(model: LearningLibraryCardModel, viewController: WeakViewController) {
        switch model.itemType {
        case .course:
            router.show(
                CourseDetailsAssembly.makeCourseDetailsViewController(
                    courseID: model.itemId,
                    enrollmentID: model.courseEnrollmentId ?? ""
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

    // MARK: - Private Functions

    private func configResponse(items: [LearningLibraryCardModel]) {
        switch pageType {
        case .details(let id, _):
            allItems = items.filter { $0.libraryId == id }
        case .completed:
            allItems = items.filter { $0.isCompleted }
        case .bookmarks:
            allItems = items.filter { $0.isBookmarked }
        }
        hasItems = allItems.isNotEmpty
    }

    private func configItem(item: LearningLibraryCardModel) {
        switch pageType {
        case .details, .completed:
            update(with: item)
        case .bookmarks:
            delete(with: item)
        }
    }

    private func update(with item: LearningLibraryCardModel) {
        if let index = allItems.firstIndex(where: { $0.id == item.id }) {
            allItems[index].update(with: item)
        }
        if let visibleIndex = self.paginator.visibleItems.firstIndex(where: { $0.id == item.id }) {
            paginator.visibleItems[visibleIndex] = item
        }
    }

    private func delete(with item: LearningLibraryCardModel) {
        allItems.removeAll(where: { item.id == $0.id })
        paginator.visibleItems.removeAll(where: { item.id == $0.id })
    }
}

extension LearningLibraryDetailsViewModel {
    enum PageType {
        case details(id: String, name: String)
        case completed
        case bookmarks
        var title: String {
            switch self {
            case .details(_, let name): name
            case .completed: String(localized: "Completed")
            case .bookmarks: String(localized: "Bookmarks")
            }
        }

        var emptyStateTitle: String {
            switch self {
            case .details: String(localized: "No content available yet")
            case .completed: String(localized: "You haven't completed any content yet")
            case .bookmarks: String(localized: "You haven't added any bookmarks yet")
            }
        }

    }
}
