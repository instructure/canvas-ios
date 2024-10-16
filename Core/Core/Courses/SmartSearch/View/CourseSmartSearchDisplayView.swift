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

public struct CourseSmartSearchDisplayView: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @Environment(\.courseSmartSearchContext) private var searchContext

    @StateObject private var viewModel = CourseSearchViewModel()
    @Binding private var filter: SearchResultFilter?

    public init(filter: Binding<SearchResultFilter?>) {
        self._filter = filter
    }

    public var body: some View {
        ZStack {
            switch viewModel.phase {
            case .loading, .start:
                SearchLoadingView()
            case .noMatch:
                SearchNoMatchView()
            case .results:
                CourseSmartSearchResultsView(results: viewModel.results)
            case .groupedResults:
                CourseSmartSearchGroupedResultsView(resultSections: viewModel.sectionedResults)
            }
        }
        .ignoresSafeArea()
        .background(Color.backgroundLight)
        .onAppear {
            guard case .start = viewModel.phase else { return }
            viewModel.filter = filter
            startLoading()
        }
        .onReceive(searchContext.didSubmit, perform: { newTerm in
            startLoading(with: newTerm)
        })
        .onChange(of: filter) { newFilter in
            viewModel.filter = newFilter
            startLoading()
        }
    }

    private func startLoading(with term: String? = nil) {
        let searchTerm = term ?? searchContext.searchText.value
        viewModel.startSearch(of: searchTerm, in: searchContext, using: env)
    }
}

#Preview {
    CourseSmartSearchDisplayView(filter: .constant(nil))
}
