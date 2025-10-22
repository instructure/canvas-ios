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

import Core
import CombineSchedulers
import Combine
import Observation
import Foundation

@Observable
final class AnnouncementsListWidgetViewModel {
    enum ViewState: Equatable {
        case loading
        case data(announcements: [NotificationModel])
    }
    // MARK: - Outputs

    private(set) var state: ViewState = .loading

    // MARK: - Private Properties

    private var subscriptions = Set<AnyCancellable>()
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var isFirstLoading = true

    // MARK: - Dependencies

    private let interactor: NotificationInteractor
    private let router: Router

    // MARK: - Init

    init(
        interactor: NotificationInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler
        fetchAnnouncements(ignoreCache: false)
    }

    // MARK: - Actions

    func navigateToAnnouncement(
        announcement: NotificationModel,
        viewController: WeakViewController
    ) {
        let vc = HorizonMessageDetailsAssembly.makeViewController(
            announcementID: announcement.announcementId.defaultToEmpty
        )
        router.show(vc, from: viewController)
    }

    func fetchAnnouncements(ignoreCache: Bool, completion: (() -> Void)? = nil) {
        if isFirstLoading {
            state = .loading
        } else if case .data(announcements: let announcements) = state, announcements.isNotEmpty {
            state = .loading
        }
        isFirstLoading = false
        interactor
            .getNotifications(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0) }
            .filter { $0.type == .announcement && ($0.isRead == false || $0.isGlobalNotification )}
            .collect()
            .receive(on: scheduler)
            .sink(receiveValue: { [weak self] notifications in
                completion?()
                self?.state = .data(announcements: notifications)
            })
            .store(in: &subscriptions)
    }
}
