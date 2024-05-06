//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

#if DEBUG

import Combine

public class CalendarFilterInteractorPreview: CalendarFilterInteractor {
    public var filters = CurrentValueSubject<[CDCalendarFilterEntry], Never>([])
    public var selectedContexts = CurrentValueSubject<Set<Context>, Never>(Set())
    public var filterCountLimit = CurrentValueSubject<CalendarFilterCountLimit, Never>(.limited(20))

    private let env = PreviewEnvironment()

    public init() {}

    public func load(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        let makeFilterEntry: (String, Context) -> CDCalendarFilterEntry = { name, context in
            let entry: CDCalendarFilterEntry = self.env.database.viewContext.insert()
            entry.name = name
            entry.context = context
            return entry
        }

        let filters: [CDCalendarFilterEntry] = {
            var filters: [CDCalendarFilterEntry] = []
            filters.append(makeFilterEntry("Test User", .user("1")))

            filters.append(makeFilterEntry("Black Holes", .course("1")))
            filters.append(makeFilterEntry("Cosmology", .course("2")))
            filters.append(makeFilterEntry("From Planets to the Cosmos", .course("3")))
            filters.append(makeFilterEntry("General Astrophysics", .course("4")))
            filters.append(makeFilterEntry("Life in The Universe", .course("5")))
            filters.append(makeFilterEntry("Planets and the Solar System", .course("6")))

            filters.append(makeFilterEntry("Black Holes Group", .group("1")))
            filters.append(makeFilterEntry("Cosmology Group", .group("2")))
            filters.append(makeFilterEntry("From Planets to the Cosmos Group", .group("3")))
            return filters
        }()

        filters.forEach { filter in
            let color: ContextColor = env.database.viewContext.insert()
            color.canvasContextID = filter.rawContextID
            color.color = .random
        }

        self.filters.send(filters)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    public func updateFilteredContexts(_ contexts: [Context], isSelected: Bool) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func contextsForAPIFiltering() -> [Context] {
        []
    }
}

#endif
