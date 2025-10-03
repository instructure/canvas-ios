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

public struct AssignmentListScreen: View, ScreenViewTrackable {
    @Environment(\.viewController) private var controller
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.appEnvironment) private var env

    @ObservedObject private var viewModel: AssignmentListScreenViewModel
    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    @State private var isShowingGradingPeriodPicker = false

    public init(viewModel: AssignmentListScreenViewModel) {
        self.viewModel = viewModel
        screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/courses/\(viewModel.courseID)/assignments"
        )
    }

    public var body: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .empty, .error:
                gradingPeriodTitle
                emptyPanda
            case .loading:
                loadingView
            case .data:
                gradingPeriodTitle
                assignmentList
            }
        }
        .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
        .tint(viewModel.courseColor?.asColor)
        .navigationBarTitleView(
            title: String(localized: "Assignments", bundle: .core),
            subtitle: viewModel.courseName
        )
        .navigationBarGenericBackButton()
        .navBarItems(
            trailing: .filterIcon(isBackgroundContextColor: true, isSolid: viewModel.isFilterIconSolid) {
                viewModel.navigateToPreferences(viewController: controller)
            }
        )
        .navigationBarStyle(.color(viewModel.courseColor))
        .onAppear(perform: viewModel.viewDidAppear)
        .onReceive(viewModel.$defaultDetailViewRoute, perform: setupDefaultSplitDetailView)
    }

    private var gradingPeriodTitle: some View {
        var text = Text("All", bundle: .core)

        if let gradingPeriodTitle = viewModel.selectedGradingPeriodTitle {
            text = Text(gradingPeriodTitle)
        }

        return Section(
            header: ListSectionHeaderOld(backgroundColor: .backgroundLightest) {
                HStack {
                    Text("Grading Period:", bundle: .core)
                        .textStyle(.sectionHeader)
                    Spacer()
                    text
                        .font(.semibold22)
                        .foregroundStyle(Color(.textDarkest))
                }
                .padding(.vertical, 8)
                .accessibilityElement()
                .accessibilityLabel(Text("Selected grading period:", bundle: .core))
                .accessibilityValue(text)
                .accessibilityRemoveTraits(.isHeader)
            },
            content: { }
        )
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

    private var assignmentList: some View {
        ScrollView {
            VStack(spacing: 0) {
                InstUI.TopDivider()
                AssignmentListView(
                    sections: viewModel.sections,
                    identifierGroup: "AssignmentList",
                    navigateToDetailsAction: {
                        viewModel.didSelectAssignment.send(($0, controller))
                    }
                )
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private func setupDefaultSplitDetailView(_ routeUrl: String) {
        guard let defaultViewProvider = controller.value as? DefaultViewProvider,
              defaultViewProvider.defaultViewRoute?.url != routeUrl
        else { return }
        defaultViewProvider.setDefaultViewRoute(.init(url: routeUrl))
    }
}

#if DEBUG

private func createSections() -> [AssignmentListSection] {
    let studentRows: [StudentAssignmentListItem] = [
        .make(
            id: "1",
            title: "Math Assignment",
            icon: .assignmentLine,
            dueDates: ["Due Sep 10, 2025 at 11:59 PM"],
            submissionStatus: .init(status: .notSubmitted),
            score: "10 / 15"
        ),
        .make(
            id: "2",
            title: "Quiz 1",
            icon: .quizLine,
            dueDates: ["Due Sep 15, 2025 at 11:59 PM"],
            submissionStatus: .init(status: .graded),
            score: "8 / 10"
        ),
        .make(
            id: "3",
            title: "Discussion Topic",
            icon: .discussionLine,
            dueDates: ["Due Sep 20, 2025 at 11:59 PM"],
            submissionStatus: .init(status: .late),
            score: "5 / 10"
        )
    ]

    return [
        AssignmentListSection(
            id: "1",
            title: "Assignment Group 1",
            rows: studentRows.map { .student($0) }
        ),
        AssignmentListSection(
            id: "2",
            title: "Assignment Group 2",
            rows: studentRows.map { .student($0) }
        )
    ]
}

#Preview("Data State") {
    let sections = createSections()
    AssignmentListScreen(viewModel: .init(state: .data, sections: sections))
}

#Preview("Empty State") {
    AssignmentListScreen(viewModel: .init(state: .empty))
}

#Preview("Loading State") {
    AssignmentListScreen(viewModel: .init(state: .loading))
}

#endif
