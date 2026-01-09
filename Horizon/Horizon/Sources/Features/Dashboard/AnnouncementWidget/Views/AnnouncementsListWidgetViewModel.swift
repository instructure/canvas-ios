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
    // MARK: - Outputs

    private(set) var state: HViewState = .loading
    private(set) var isCounterViewVisible = false
    private(set) var announcements: [AnnouncementModel] = []

    // MARK: - Input/Outputs

    var currentCardIndex: Int? = 0

    // MARK: - Private Properties

    private var subscriptions = Set<AnyCancellable>()
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var isFirstLoading = true

    // MARK: - Dependencies

    private let interactor: AnnouncementInteractor
    private let router: Router

    // MARK: - Init

    init(
        interactor: AnnouncementInteractor,
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
        announcement: AnnouncementModel,
        viewController: WeakViewController
    ) {
        let vc = HorizonMessageDetailsAssembly.makeAnnouncementView(announcementModel: announcement)
        router.show(vc, from: viewController)
        markAsRead(announcement: announcement)
    }

    private func markAsRead(announcement: AnnouncementModel) {
        interactor.markAnnouncementAsRead(announcement: announcement)
            .flatMap { Publishers.Sequence(sequence: $0) }
            .filter { $0.isRead == false }
            .receive(on: scheduler)
            .collect()
            .sink { [weak self] announcements in
                guard let self else { return }
                self.handleResponse(announcements: announcements)
            }
            .store(in: &subscriptions)
    }

    func fetchAnnouncements(ignoreCache: Bool, completion: (() -> Void)? = nil) {
        if isFirstLoading {
            state = .loading
        } else if announcements.isNotEmpty {
            state = .loading
        }
        currentCardIndex = 0
        announcements = [AnnouncementModel.mock]
        isFirstLoading = false
        interactor
            .getAllAnnouncements(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0) }
            .filter { $0.isRead == false }
            .collect()
            .receive(on: scheduler)
            .sink { [weak self] notifications in
                guard let self else { return }
                self.handleResponse(announcements: notifications)
                completion?()
            }
            .store(in: &subscriptions)
    }

    private func handleResponse(announcements: [AnnouncementModel]) {
        state = announcements.isEmpty ? .empty : .data
        self.announcements = announcements
        isCounterViewVisible = announcements.count > 1
        currentCardIndex = .zero
    }
}
