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
    public var filterCountLimit = CurrentValueSubject<CalendarFilterCountLimit, Never>(.extended)
    public var mockedFilters: [(String, Context)] = [
        ("Test User", .user("1")),

        ("Black Holes", .course("1")),
        ("Cosmology", .course("2")),
        ("From Planets to the Cosmos", .course("3")),
        ("General Astrophysics", .course("4")),
        ("Life in The Universe", .course("5")),
        ("Planets and the Solar System", .course("6")),

        ("Black Holes Group", .group("1")),
        ("Cosmology Group", .group("2")),
        ("From Planets to the Cosmos Group", .group("3")),
    ] {
        didSet {
            isMockedDataChangedSinceTheLastLoad = true
        }
    }

    private let env = PreviewEnvironment()
    private var isMockedDataChangedSinceTheLastLoad = false

    public init() {}

    public func load(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        guard isMockedDataChangedSinceTheLastLoad else {
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        isMockedDataChangedSinceTheLastLoad = false
        return loadFilters(with: mockedFilters)
    }

    public func updateFilteredContexts(_ contexts: [Context], isSelected: Bool) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func contextsForAPIFiltering() -> [Context] {
        []
    }

    private func loadFilters(with parameters: [(String, Context)]) -> AnyPublisher<Void, Error> {
        let filters: [CDCalendarFilterEntry] = parameters.map { name, context in
            let filter: CDCalendarFilterEntry = env.database.viewContext.insert()
            filter.name = name
            filter.context = context

            let color: ContextColor = env.database.viewContext.insert()
            color.canvasContextID = filter.rawContextID
            color.color = .random

            return filter
        }

        self.filters.send(filters)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

#endif
