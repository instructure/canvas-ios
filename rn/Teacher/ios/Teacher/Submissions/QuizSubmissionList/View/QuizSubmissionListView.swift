//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

struct QuizSubmissionListView: View {
    @ObservedObject private var viewModel: QuizSubmissionListViewModel

    init(viewModel: QuizSubmissionListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        switch viewModel.state {
        case .loading:
            Text("Loading")
        case .error:
            Text("Something went wrong")
        case .empty:
            Text("No submissions")
        case .data:
            submissionList
        }
    }

    var submissionList: some View {
        List {
//            ForEach(viewModel.submissions) { _ in
//                Text("item")
//            }
        }
    }
}
