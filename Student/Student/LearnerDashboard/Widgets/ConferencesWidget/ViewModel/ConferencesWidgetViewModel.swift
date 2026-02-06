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
import CoreData
import Foundation
import Observation

@Observable
final class ConferencesWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = ConferencesWidgetView

    let config: DashboardWidgetConfig
    var id: DashboardWidgetIdentifier { config.id }
    let isFullWidth = true
    let isEditable = false

    private(set) var conferences: [ConferenceCardViewModel] = [] {
        didSet { updateTitles() }
    }
    private(set) var state: InstUI.ScreenState = .loading
    private(set) var widgetTitle: String = ""
    private(set) var widgetAccessibilityTitle: String = ""

    var layoutIdentifier: AnyHashable {
        struct Identifier: Hashable {
            let state: InstUI.ScreenState
            let conferenceCount: Int
        }
        return AnyHashable(Identifier(state: state, conferenceCount: conferences.count))
    }

    private let interactor: CoursesInteractor
    private let context: NSManagedObjectContext
    private let environment: AppEnvironment
    private let snackBarViewModel: SnackBarViewModel
    private var subscriptions = Set<AnyCancellable>()

    init(
        config: DashboardWidgetConfig,
        interactor: CoursesInteractor,
        snackBarViewModel: SnackBarViewModel,
        context: NSManagedObjectContext = AppEnvironment.shared.database.backgroundReadContext,
        environment: AppEnvironment = .shared
    ) {
        self.config = config
        self.interactor = interactor
        self.context = context
        self.environment = environment
        self.snackBarViewModel = snackBarViewModel
        updateTitles()
    }

    func makeView() -> ConferencesWidgetView {
        ConferencesWidgetView(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        let conferencesStore = ReactiveStore(
            context: context,
            useCase: GetLiveConferences(),
            environment: environment
        )

        return Publishers.Zip(
            conferencesStore.getEntities(ignoreCache: ignoreCache),
            interactor.getCourses(ignoreCache: ignoreCache)
        )
        .map { [weak self] (conferences: [Conference], coursesResult: CoursesResult) -> [ConferenceCardViewModel] in
            guard let self else { return [] }
            return conferences.compactMap { conference -> ConferenceCardViewModel? in
                guard let contextName = self.resolveContextName(
                    for: conference,
                    coursesResult: coursesResult
                ) else {
                    return nil
                }
                return ConferenceCardViewModel(
                    id: conference.id,
                    title: conference.title,
                    contextName: contextName,
                    context: conference.context,
                    joinURL: conference.joinURL,
                    environment: self.environment,
                    snackBarViewModel: self.snackBarViewModel,
                    onDismiss: { [weak self] conferenceId in
                        self?.dismissConference(conferenceId: conferenceId)
                    }
                )
            }
        }
        .receive(on: DispatchQueue.main)
        .map { [weak self] conferences in
            self?.conferences = conferences
            self?.state = conferences.isEmpty ? .empty : .data
            return ()
        }
        .catch { [weak self] _ in
            self?.state = .error
            return Just(())
        }
        .eraseToAnyPublisher()
    }

    private func resolveContextName(
        for conference: Conference,
        coursesResult: CoursesResult
    ) -> String? {
        if conference.context.contextType == .group {
            coursesResult.groups.first { $0.id == conference.context.id }?.name
        } else {
            coursesResult.allCourses.first { $0.id == conference.context.id }?.name
        }
    }

    private func dismissConference(conferenceId: String) {
        context.perform { [weak self] in
            guard let self else { return }
            let conference: Conference? = context.first(where: #keyPath(Conference.id), equals: conferenceId)
            conference?.isIgnored = true
            try? context.save()

            DispatchQueue.main.async {
                self.removeConference(id: conferenceId)
            }
        }
    }

    @MainActor
    private func removeConference(id: String) {
        conferences.removeAll { $0.id == id }
        if conferences.isEmpty {
            state = .empty
        }
    }

    private func updateTitles() {
        let count = conferences.count
        widgetTitle = String(localized: "Live Conferences (\(count))", bundle: .student)
        widgetAccessibilityTitle = [
            String(localized: "Live Conferences", bundle: .student),
            String.format(numberOfItems: count)
        ].joined(separator: ", ")
    }
}
