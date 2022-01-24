//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct AssignmentListView: View {

    @ObservedObject private var viewModel: AssignmentListViewModel
    @State private var isShowingGradingPeriodPicker = false

    public init(viewModel: AssignmentListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            HStack {
                if let gradingPeriodTitle = viewModel.selectedGradingPeriod?.title {
                    Text(gradingPeriodTitle).font(.bold20)
                } else {
                    Text("All", bundle: .core).font(.bold20)
                }
                Spacer(minLength: 8)
                if (viewModel.selectedGradingPeriod == nil) {
                    Button(action: {
                        isShowingGradingPeriodPicker = true
                    }, label: {
                        Text("Filter", bundle: .core)
                    }).actionSheet(isPresented: $isShowingGradingPeriodPicker) {
                        ActionSheet(title: Text("Filter by", bundle: .core), buttons: gradingPeriodButtons)
                    }
                } else {
                    Button(action: {
                        viewModel.gradingPeriodSelected(nil)
                    }, label: {
                        Text("Clear Filter", bundle: .core)
                    })
                }
            }.padding(16)
            List {
                ForEach(viewModel.assignmentGroups, id: \.id) { assignmentGroup in
                    AssignmentGroupView(viewModel: assignmentGroup)
                }
            }
            .listStyle(.plain)
        }
        .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
        .navigationBarStyle(.color(viewModel.courseColor))
        .navigationTitle(NSLocalizedString("Assignments", comment: ""), subtitle: viewModel.courseName)
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    private var gradingPeriodButtons: [ActionSheet.Button] {
        viewModel.gradingPeriods.all.map { gradingPeriod in
            ActionSheet.Button.default(Text(gradingPeriod.title ?? "")) {
                viewModel.gradingPeriodSelected(gradingPeriod)
                isShowingGradingPeriodPicker = false
            }
        }
    }
}

#if DEBUG
struct AssignmentListView_Previews: PreviewProvider {
    static var previews: some View {

        let viewModel = AssignmentListViewModel(context: Context(.course, id: "1"))
        AssignmentListView(viewModel: viewModel)
    }
}
#endif
