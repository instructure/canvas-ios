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

public struct AssignmentListView: View, ScreenViewTrackable {
    @Environment(\.viewController) private var controller
    @ObservedObject private var viewModel: AssignmentListViewModel
    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    @State private var isShowingGradingPeriodPicker = false

    public init(viewModel: AssignmentListViewModel) {
        self.viewModel = viewModel
        screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/courses/\(viewModel.courseID)/assignments"
        )
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                gradingPeriodTitle
                Spacer(minLength: 8)
                if viewModel.shouldShowFilterButton {
                    gradingPeriodButton
                }
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))

            switch viewModel.state {
            case .empty:
                emptyPanda
            case .loading:
                loadingView
            case .data(let groups):
                assignmentList(groups)
            }
        }
        .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
        .navigationBarStyle(.color(viewModel.courseColor))
        .navigationTitle(NSLocalizedString("Assignments", comment: ""), subtitle: viewModel.courseName)
        .navigationBarGenericBackButton()
        .onAppear(perform: viewModel.viewDidAppear)
        .onReceive(viewModel.$defaultDetailViewRoute, perform: setupDefaultSplitDetailView)
    }

    private var gradingPeriodTitle: some View {
        var text = Text("All", bundle: .core)

        if let gradingPeriodTitle = viewModel.selectedGradingPeriod?.title {
            text = Text(gradingPeriodTitle)
        }

        return text
            .font(.heavy24)
            .accessibility(addTraits: .isHeader)
    }

    @ViewBuilder
    private var gradingPeriodButton: some View {
        if viewModel.selectedGradingPeriod == nil {
            Button(action: {
                isShowingGradingPeriodPicker = true
            }, label: {
                Text("Filter", bundle: .core)
                    .font(.semibold16)
                    .foregroundColor(Color(Brand.shared.linkColor))
            }).actionSheet(isPresented: $isShowingGradingPeriodPicker) {
                ActionSheet(title: Text("Filter by", bundle: .core), buttons: gradingPeriodButtons)
            }
        } else {
            Button(action: viewModel.gradingPeriodFilterCleared) {
                Text("Clear Filter", bundle: .core)
                    .font(.semibold16)
                    .foregroundColor(Color(Brand.shared.linkColor))
            }
        }
    }

    private var gradingPeriodButtons: [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = viewModel.gradingPeriods.all.map { gradingPeriod in
            ActionSheet.Button.default(Text(gradingPeriod.title ?? "")) {
                viewModel.gradingPeriodSelected(gradingPeriod)
                isShowingGradingPeriodPicker = false
            }
        }
        buttons.append(.cancel(Text("Cancel", bundle: .core)))
        return buttons
    }

    @ViewBuilder
    private var emptyPanda: some View {
        Divider()
        GeometryReader { geometry in
            List {
                EmptyPanda(.NoEvents, title: Text("No Assignments", bundle: .core), message: Text("There are no assignments to display.", bundle: .core))
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height)
                    .background(Color.backgroundLightest)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(SwiftUI.EmptyView())
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        Divider()
        Spacer()
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
        Spacer()
    }

    private func assignmentList(_ groups: [AssignmentGroupViewModel]) -> some View {
        List {
            ForEach(groups, id: \.id) { assignmentGroup in
                AssignmentGroupView(viewModel: assignmentGroup)
                    .listRowBackground(SwiftUI.EmptyView())
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private func setupDefaultSplitDetailView(_ route: String) {
        guard let defaultViewProvider = controller.value as? DefaultViewProvider, defaultViewProvider.defaultViewRoute != route else { return }
        defaultViewProvider.defaultViewRoute = route
    }
}

#if DEBUG

struct AssignmentListView_Previews: PreviewProvider {
    private static let env = PreviewEnvironment()
    private static let context = env.globalDatabase.viewContext
    private static func createAssignments() -> [Assignment] {
        let assignments: [APIAssignment] = [
            APIAssignment.make(needs_grading_count: 0),
            APIAssignment.make(id: "2", quiz_id: "1"),
            APIAssignment.make(id: "3", submission_types: [.discussion_topic]),
            APIAssignment.make(id: "4", submission_types: [.external_tool]),
            APIAssignment.make(id: "5", locked_for_user: true),
        ]
        return assignments.map {
            Assignment.save($0, in: context, updateSubmission: false, updateScoreStatistics: false)
        }
    }

    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = UITableView.setupDefaultSectionHeaderTopPadding()

        let assignments = createAssignments()
        let assignmentGroups: [AssignmentGroupViewModel] = [
            AssignmentGroupViewModel(name: "Assignment Group 1", id: "1", assignments: assignments, courseColor: .red),
            AssignmentGroupViewModel(name: "Assignment Group 2", id: "2", assignments: assignments, courseColor: .red),
        ]
        let viewModel = AssignmentListViewModel(state: .data(assignmentGroups))
        AssignmentListView(viewModel: viewModel)

        let emptyModel = AssignmentListViewModel(state: .empty)
        AssignmentListView(viewModel: emptyModel)

        let loadingModel = AssignmentListViewModel(state: .loading)
        AssignmentListView(viewModel: loadingModel)
    }
}

#endif
