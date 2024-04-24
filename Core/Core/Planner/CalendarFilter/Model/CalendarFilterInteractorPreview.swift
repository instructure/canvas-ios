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
    private let env = PreviewEnvironment()

    public required init(observedUserId: String?, env: AppEnvironment) {

    }

    public func observeFilter() -> AnyPublisher<CDCalendarFilter, Never> {
        let filter: CDCalendarFilter = env.database.viewContext.insert()

        let makeFilterEntry: (String, Context) -> CDCalendarFilterEntry = { name, context in
            let entry: CDCalendarFilterEntry = self.env.database.viewContext.insert()
            entry.name = name
            entry.context = context
            entry.filter = filter
            return entry
        }

        filter.entries = {
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
            return Set(filters)
        }()

        filter.entries.forEach { filter in
            let color: ContextColor = env.database.viewContext.insert()
            color.canvasContextID = filter.rawContextID
            color.color = .random
        }

        return Just(filter).eraseToAnyPublisher()
    }

    public func load(ignoreCache: Bool) -> any Publisher<Void, Error> {
        Just(()).setFailureType(to: Error.self)
    }

    public func updateFilteredContext(_ context: Context, isSelected: Bool) {
    }

    public func selectAll() {
    }

    public func deselectAll() {
    }
}

#endif
