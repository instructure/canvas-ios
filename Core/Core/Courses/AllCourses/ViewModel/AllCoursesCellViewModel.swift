//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import CombineExt
import SwiftUI
import CombineSchedulers

public class AllCoursesCellViewModel: ObservableObject {
    public enum Item {
        case course(AllCoursesCourseItem)
        case group(AllCoursesGroupItem)
    }

    // MARK: - Dependencies

    private let offlineModeInteractor: OfflineModeInteractor
    private let app: AppEnvironment.App?
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Outputs

    @Published public private(set) var item: Item
    @Published public private(set) var isCellDisabled = false
    @Published public private(set) var isFavoriteStarDisabled: Bool = false
    @Published public private(set) var pending = false
    @Published public private(set) var favoriteButtonAccessibilityText: String = ""
    @Published public private(set) var favoriteButtonTraits: AccessibilityTraits = []

    public private(set) var isOfflineIndicatorVisible: Bool = false
    public private(set) var cellAccessibilityLabelText: String = ""

    // MARK: - Private properties

    private let isItemAvailableOffline: Bool
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Inputs

    let cellDidTap = PassthroughRelay<WeakViewController>()
    let toggleFavoriteDidTap = PassthroughRelay<Void>()

    init(
        item: Item,
        offlineModeInteractor: OfflineModeInteractor,
        sessionDefaults: SessionDefaults,
        app: AppEnvironment.App?,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.item = item
        self.offlineModeInteractor = offlineModeInteractor
        self.app = app
        self.router = router
        self.scheduler = scheduler

        switch item {
        case let .course(course):
            isItemAvailableOffline = sessionDefaults.offlineSyncSelections.contains {
                $0.contains("courses/\(course.courseId)")
            }
        case .group:
            isItemAvailableOffline = false
        }

        setuProperties()
        setupBindings()
    }

    private func setuProperties() {
        isCellDisabled = !item.isDetailsAvailable || !calculateIsCourseEnabled(offlineModeInteractor.isOfflineModeEnabled())
        isOfflineIndicatorVisible = isItemAvailableOffline
        isFavoriteStarDisabled = offlineModeInteractor.isOfflineModeEnabled()

        let offlineText = isOfflineIndicatorVisible ? String(localized: "Available offline", bundle: .core) : nil
        let publishedText = !(app == .teacher) ? nil : item.isPublished ?
            String(localized: "published", bundle: .core) :
            String(localized: "unpublished", bundle: .core)
        cellAccessibilityLabelText = [
            item.name,
            item.termName,
            item.roles,
            offlineText,
            publishedText
        ]
        .compactMap { $0 }.joined(separator: ", ")

        favoriteButtonAccessibilityText = pending ? String(localized: "Updating", bundle: .core) : String(localized: "Favorite", bundle: .core)
        favoriteButtonTraits = (item.isFavourite && !pending) ? .isSelected : []
    }

    private func setupBindings() {
        unowned let unownedSelf = self

        toggleFavoriteDidTap
            .receive(on: scheduler)
            .sink { [weak self] in self?.toggleFavorite() }
            .store(in: &subscriptions)

        cellDidTap
            .sink { unownedSelf.router.route(to: unownedSelf.item.path, from: $0) }
            .store(in: &subscriptions)

        offlineModeInteractor
            .observeIsOfflineMode()
            .assign(to: &$isFavoriteStarDisabled)

        offlineModeInteractor
            .observeIsOfflineMode()
            .map { unownedSelf.calculateIsCourseEnabled($0) }
            .map { !unownedSelf.item.isDetailsAvailable || !$0 }
            .receive(on: scheduler)
            .assign(to: &$isCellDisabled)
    }

    private func calculateIsCourseEnabled(_ isInOfflineMode: Bool) -> Bool {
        isInOfflineMode ? isItemAvailableOffline : true
    }

    private func toggleFavorite() {
        guard !pending else { return }
        withAnimation { pending = true }
        switch item {
        case .group:
            MarkFavoriteGroup(
                groupID: item.id,
                markAsFavorite: !item.isFavourite
            ).fetch { _, _, _ in
                performUIUpdate {
                    withAnimation { [weak self] in
                        self?.pending = false
                    }
                }
            }
        case .course:
            MarkFavoriteCourse(
                courseID: item.id, markAsFavorite:
                !item.isFavourite
            ).fetch { _, _, _ in
                performUIUpdate {
                    withAnimation { [weak self] in
                        self?.pending = false
                    }
                }
            }
        }
    }
}

extension AllCoursesCellViewModel.Item {
    var id: String {
        switch self {
        case let .course(course): return course.courseId
        case let .group(group): return group.id
        }
    }

    var name: String {
        switch self {
        case let .course(course): return course.name
        case let .group(group): return group.name
        }
    }

    var isFavourite: Bool {
        switch self {
        case let .course(course): return course.isFavorite
        case let .group(group): return group.isFavorite
        }
    }

    var path: String {
        switch self {
        case let .course(course): return "/courses/\(course.courseId)"
        case let .group(group): return "/groups/\(group.id)"
        }
    }

    var termName: String? {
        switch self {
        case let .course(course): return course.termName
        case let .group(group): return group.courseTermName
        }
    }

    var roles: String? {
        switch self {
        case let .course(course): return course.roles
        case let .group(group): return group.courseRoles
        }
    }

    var isPublished: Bool {
        switch self {
        case let .course(course): return course.isPublished
        case .group: return true
        }
    }

    var isFavoriteButtonVisible: Bool {
        switch self {
        case let .course(course): return course.isFavoriteButtonVisible
        case .group: return true
        }
    }

    var isDetailsAvailable: Bool {
        switch self {
        case let .course(course): return course.isCourseDetailsAvailable
        case .group: return true
        }
    }
}
