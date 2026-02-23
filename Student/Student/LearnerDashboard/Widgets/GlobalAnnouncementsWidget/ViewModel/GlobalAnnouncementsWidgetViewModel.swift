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

@Observable
final class GlobalAnnouncementsWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = GlobalAnnouncementsWidgetView

    let config: DashboardWidgetConfig
    let isFullWidth = true
    let isEditable = false

    private(set) var state: InstUI.ScreenState = .loading
    private(set) var announcements: [GlobalAnnouncementCardViewModel] = []
    private(set) var widgetTitle: String = ""
    private(set) var widgetAccessibilityTitle: String = ""

    var layoutIdentifier: [AnyHashable] {
        [state, announcements.count]
    }

    private let interactor: GlobalAnnouncementsWidgetInteractor
    private let environment: AppEnvironment

    private var subscriptions = Set<AnyCancellable>()

    init(
        config: DashboardWidgetConfig,
        interactor: GlobalAnnouncementsWidgetInteractor,
        environment: AppEnvironment = .shared
    ) {
        self.config = config
        self.interactor = interactor
        self.environment = environment

        observeAnnouncements()
        updateWidgetTitle()
    }

    func makeView() -> GlobalAnnouncementsWidgetView {
        GlobalAnnouncementsWidgetView(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        // This just loads the data. They are handled in the observe method below.
        // This allows automatic removal of dismissed items.
        interactor.loadAnnouncements(ignoreCache: ignoreCache)
            .receive(on: DispatchQueue.main)
            .catch { [weak self] _ in
                self?.state = .error
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    private func observeAnnouncements() {
        interactor.observeAnnouncements()
            .map { [weak self] items -> [GlobalAnnouncementCardViewModel] in
                items
                    .sorted { $0.startDate ?? Date.distantPast > $1.startDate ?? Date.distantPast }
                    .map { item in
                        GlobalAnnouncementCardViewModel(
                            model: item,
                            onCardTap: { controller in
                                self?.showDetails(for: item, from: controller)
                            }
                        )
                    }
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] in
                    if $0.isFailure {
                        self?.state = .error
                    }
                },
                receiveValue: { [weak self] announcements in
                    self?.announcements = announcements
                    self?.didUpdateAnnouncements()
                }
            )
            .store(in: &subscriptions)
    }

    private func didUpdateAnnouncements() {
        state = announcements.isEmpty ? .empty : .data
        updateWidgetTitle()
    }

    private func showDetails(
        for item: GlobalAnnouncementsWidgetItem,
        from controller: WeakViewController
    ) {
        let viewModel = GlobalAnnouncementDetailsViewModel(
            item: item,
            interactor: interactor,
            environment: environment
        )
        let detailsVC = CoreHostingController(
            GlobalAnnouncementDetailsScreen(viewModel: viewModel)
        )

        environment.router.show(
            detailsVC,
            from: controller,
            options: .modal(isDismissable: true, embedInNav: true)
        )
    }

    private func updateWidgetTitle() {
        let count = announcements.count
        widgetTitle = String(localized: "Announcements (\(count))", bundle: .student)
        widgetAccessibilityTitle = [
            String(localized: "Announcements", bundle: .student),
            String.format(numberOfItems: count)
        ].joined(separator: ", ")
    }
}
