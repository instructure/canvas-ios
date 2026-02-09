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

protocol ConferencesWidgetInteractor {
    func getConferences(ignoreCache: Bool) -> AnyPublisher<[ConferencesWidgetItem], Error>
    func dismissConference(id: String) -> AnyPublisher<Void, Never>
}

extension ConferencesWidgetInteractor where Self == ConferencesWidgetInteractorLive {
    static func live(coursesInteractor: CoursesInteractor, env: AppEnvironment) -> ConferencesWidgetInteractorLive {
        .init(coursesInteractor: coursesInteractor, env: env)
    }
}

final class ConferencesWidgetInteractorLive: ConferencesWidgetInteractor {
    private let coursesInteractor: CoursesInteractor
    private let moContext: NSManagedObjectContext

    private let conferencesStore: ReactiveStore<GetLiveConferences>

    init(
        coursesInteractor: CoursesInteractor,
        env: AppEnvironment
    ) {
        self.coursesInteractor = coursesInteractor
        self.moContext = env.database.viewContext

        self.conferencesStore = ReactiveStore(
            context: moContext,
            useCase: GetLiveConferences(),
            environment: env
        )
    }

    // MARK: - Get Conferences

    func getConferences(ignoreCache: Bool) -> AnyPublisher<[ConferencesWidgetItem], Error> {
        Publishers.Zip(
            conferencesStore.getEntities(ignoreCache: ignoreCache),
            coursesInteractor.getCourses(ignoreCache: ignoreCache)
        )
        .map { [weak self] (conferences: [Conference], coursesResult: CoursesResult) -> [ConferencesWidgetItem] in
            conferences.compactMap {
                self?.conferenceItem(with: $0, coursesResult: coursesResult)
            }
        }
        .eraseToAnyPublisher()
    }

    private func conferenceItem(with conference: Conference, coursesResult: CoursesResult) -> ConferencesWidgetItem? {
        guard let contextName = resolveContextName(for: conference, coursesResult: coursesResult) else {
            return nil
        }

        let joinRoute = "\(conference.context.pathComponent)/conferences/\(conference.id)/join"

        return ConferencesWidgetItem(
            id: conference.id,
            title: conference.title,
            contextName: contextName,
            joinRoute: joinRoute,
            joinUrl: conference.joinURL
        )
    }

    private func resolveContextName(for conference: Conference, coursesResult: CoursesResult) -> String? {
        if conference.context.contextType == .group {
            coursesResult.groups.first { $0.id == conference.context.id }?.name
        } else {
            coursesResult.allCourses.first { $0.id == conference.context.id }?.name
        }
    }

    // MARK: - Dismiss

    func dismissConference(id: String) -> AnyPublisher<Void, Never> {
        Future { [weak self] promise in
            guard let self else {
                promise(.success)
                return
            }

            moContext.perform { [weak self] in
                guard let self else { return }

                let conference: Conference? = moContext.first(where: \Conference.id, equals: id)
                conference?.isIgnored = true
                try? moContext.save()

                promise(.success)
            }
        }
        .eraseToAnyPublisher()
    }
}
