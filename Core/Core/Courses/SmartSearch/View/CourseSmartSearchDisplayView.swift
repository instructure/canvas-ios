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

    @Environment(\.viewController) private var controller
    @Environment(\.courseSmartSearchContext) private var searchContext

    @StateObject private var viewModel: CourseSmartSearchViewModel
    @Binding private var filter: CourseSmartSearchFilter?

    init(viewModel: CourseSmartSearchViewModel, filter: Binding<CourseSmartSearchFilter?>) {
        self._filter = filter
        self._viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            switch viewModel.phase {
            case .loading, .start:
                SearchLoadingView()
            case .noMatch:
                SearchNoMatchView()
            case .results:
                CourseSmartSearchResultsView(
                    course: viewModel.course,
                    results: viewModel.results
                )
            case .groupedResults:
                CourseSmartSearchGroupedResultsView(
                    course: viewModel.course,
                    resultSections: viewModel.sectionedResults
                )
            }
        }
        .background(Color.backgroundLight)
        .onAppear {
            guard case .start = viewModel.phase else { return }
            viewModel.fetchCourse()
            resetFilter(filter)
        }
        .onReceive(searchContext.didSubmit, perform: { newTerm in
            startLoading(with: newTerm)
        })
        .onChange(of: filter) { newFilter in
            resetFilter(newFilter)
        }
    }

    private func resetFilter(_ filter: CourseSmartSearchFilter?) {
        viewModel.filter = filter
        startLoading()
    }

    private func startLoading(with term: String? = nil) {
        viewModel.startSearch(of: term ?? searchContext.searchText.value)
    }
}

#if DEBUG
#Preview {
    CourseSmartSearchDisplayView(
        viewModel: CourseSmartSearchViewModel(
            interactor: CourseSmartSearchInteractorPreview()
        ),
        filter: .constant(nil)
    )
}
#endif
