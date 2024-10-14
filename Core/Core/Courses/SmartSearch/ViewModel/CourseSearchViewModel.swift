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

import SwiftUI

class CourseSearchViewModel: ObservableObject {

    enum Phase {
        case start
        case loading
        case noMatch
        case results
        case groupedResults
    }

    @Published private(set) var phase: Phase = .start
    @Published private(set) var results: [SearchResult] = []
    @Published var filter: SearchResultFilter?

    var sectionedResults: [SearchResultsSection] {
        let filtered = filter.flatMap { filter in
            return results.filter(filter.predicate)
        } ?? results

        var list = Dictionary(grouping: filtered, by: { $0.content_type })
            .map({
                SearchResultsSection(
                    type: $0,
                    results: $1
                )
            })
            .sorted(by: { $0.type.sortOrder < $1.type.sortOrder})

        if var first = list.first {
            first.expanded = true
            list[0] = first
        }

        return list
    }

    func startSearch(
        of searchTerm: String,
        in context: CoreSearchContext,
        using env: AppEnvironment
    ) {
        guard let courseId = context.context.courseId else { return }

        phase = .loading

        env
            .api
            .makeRequest(
                CourseSmartSearchRequest(
                    courseId: courseId,
                    searchText: searchTerm,
                    filter: filter?.includedTypes.map({ $0.filterValue })
                ),
                callback: { results, _, _ in
                    DispatchQueue.main.async { [weak self] in
                        self?.updateResults(results?.results)
                    }
                }
            )
    }

    func updateResults(_ results: [SearchResult]?) {
        self.results = results ?? []
        applyFilters()
    }

    func applyFilters() {

        // No match
        if self.results.isEmpty {
            phase = .noMatch
            return
        }

        guard let filter else {
            // No filter
            phase = .results
            return
        }

        // Filterd results
        if case .type = filter.sortMode {
            phase = .groupedResults
        } else {
            phase = .results
        }
    }
}
