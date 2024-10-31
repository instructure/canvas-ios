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
import Combine

class CourseSmartSearchViewModel: ObservableObject {

    public enum Phase {
        case start
        case loading
        case noMatch
        case results
        case groupedResults
    }

    @Published private(set) var course: Course?
    @Published private(set) var results: [CourseSmartSearchResult] = []
    @Published private(set) var phase: Phase = .start {
        didSet {
            switch phase {
            case .results, .groupedResults:
                feedbackGenerator.impactOccurred()
            default: break
            }
        }
    }

    @Published var filter: CourseSmartSearchFilter?

    private let context: Context
    private var interactor: CourseSmartSearchInteractor
    private var feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    init(context: Context, interactor: CourseSmartSearchInteractor) {
        self.context = context
        self.interactor = interactor
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

    func fetchCourse() {
        interactor
            .fetchCourse(context: context)
            .receive(on: DispatchQueue.main)
            .assign(to: &$course)
    }

    func startSearch(of searchTerm: String) {
        phase = .loading

        let share = interactor
            .startSearch(in: context, of: searchTerm, filter: filter)
            .receive(on: DispatchQueue.main)
            .share()

        share
            .assign(to: &$results)

        share
            .map { [weak self] results in
                guard results.isEmpty == false else { return .noMatch }
                guard let filter = self?.filter else { return .results }

                if case .type = filter.sortMode {
                    return .groupedResults
                } else {
                    return .results
                }
            }
            .assign(to: &$phase)
    }
}
