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

class CourseSmartSearchViewModel: ObservableObject {

    enum Phase {
        case start
        case loading
        case noMatch
        case results
        case groupedResults
    }

    private var feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    @Published private(set) var phase: Phase = .start {
        didSet {
            switch phase {
            case .results, .groupedResults:
                feedbackGenerator.impactOccurred()
            default: break
            }
        }
    }

    @Published private(set) var results: [CourseSmartSearchResult] = []
    @Published var filter: CourseSmartSearchFilter?

    let sortStrategy: (CourseSmartSearchResult, CourseSmartSearchResult) -> Bool = { (result1, result2) in
        // First: Sort on relevance
        // Ideally, API should be returning results sorted according to relevance,
        // This is to double check on this, in addition to unit testing.
        if result1.relevance != result2.relevance {
            return result1.relevance > result2.relevance
        }

        // Then: Sort on alphabetical order
        return result1.title < result2.title
    }

    var sectionedResults: [CourseSmartSearchResultsSection] {
        let filtered = filter.flatMap { filter in
            return results.filter(filter.apply(to:))
        } ?? results

        var list = Dictionary(grouping: filtered, by: { $0.content_type })
            .map({
                CourseSmartSearchResultsSection(
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
        in context: CoreSearchContext<CourseSmartSearch>,
        using env: AppEnvironment
    ) {
        guard let courseId = context.info.context.courseId else { return }
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

    private func updateResults(_ results: [CourseSmartSearchResult]?) {
        self.results = (results ?? []).sorted(by: sortStrategy)
        applyFilter()
    }

    private func applyFilter() {

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
