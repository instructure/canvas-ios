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
final class ConferencesWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = ConferencesWidgetView

    let config: DashboardWidgetConfig
    let isFullWidth = true
    let isEditable = false
    let isHiddenInEmptyState = true

    private(set) var state: InstUI.ScreenState = .loading
    private(set) var conferences: [ConferenceCardViewModel] = []
    private(set) var widgetTitle: String = ""
    private(set) var widgetAccessibilityTitle: String = ""

    var layoutIdentifier: [AnyHashable] {
        [state, conferences.count]
    }

    private let interactor: ConferencesWidgetInteractor
    private let environment: AppEnvironment
    private let snackBarViewModel: SnackBarViewModel

    private var subscriptions = Set<AnyCancellable>()

    init(
        config: DashboardWidgetConfig,
        interactor: ConferencesWidgetInteractor,
        snackBarViewModel: SnackBarViewModel,
        environment: AppEnvironment = .shared
    ) {
        self.config = config
        self.interactor = interactor
        self.environment = environment
        self.snackBarViewModel = snackBarViewModel
        updateWidgetTitle()
    }

    func makeView() -> ConferencesWidgetView {
        ConferencesWidgetView(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        interactor.getConferences(ignoreCache: ignoreCache)
            .map { [weak self, environment, snackBarViewModel] items -> [ConferenceCardViewModel] in
                items.map { item in
                    ConferenceCardViewModel(
                        model: item,
                        snackBarViewModel: snackBarViewModel,
                        environment: environment,
                        onDismiss: { conferenceId in
                            self?.dismissConference(id: conferenceId)
                        }
                    )
                }
                .sorted { $0.id < $1.id }
            }
            .receive(on: DispatchQueue.main)
            .map { [weak self] conferences in
                self?.conferences = conferences
                self?.didUpdateConferences()
                return ()
            }
            .catch { [weak self] _ in
                self?.state = .error
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    private func dismissConference(id: String) {
        interactor.dismissConference(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.conferences.removeAll { $0.id == id }
                self?.didUpdateConferences()
            }
            .store(in: &subscriptions)
    }

    private func didUpdateConferences() {
        state = conferences.isEmpty ? .empty : .data
        updateWidgetTitle()
    }

    private func updateWidgetTitle() {
        let count = conferences.count
        widgetTitle = String(localized: "Live Conferences (\(count))", bundle: .student)
        widgetAccessibilityTitle = [
            String(localized: "Live Conferences", bundle: .student),
            String.format(numberOfItems: count)
        ].joined(separator: ", ")
    }
}
