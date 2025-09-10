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
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                InstUI.TopDivider()
                ForEach(viewModel.sections) { section in
                    sectionView(with: section)
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private func sectionView(with section: AssignmentListSection) -> some View {
        InstUI.CollapsibleListSection(title: section.title, itemCount: section.rows.count) {
            ForEach(section.rows) { row in
                switch row {
                case .student(let model):
                    studentCell(model: model, isLastItem: section.rows.last == row)
                case .teacher(let model):
                    TeacherAssignmentListItemCell(model: model, isLastItem: section.rows.last == row) {
                        viewModel.didSelectAssignment.send((model.route, controller))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func studentCell(model: StudentAssignmentListItem, isLastItem: Bool) -> some View {
        let routeAction = { navigateToDetails(at: model.route) }
        let identifier = "AssignmentList.\(model.id)"

        if let subAssignments = model.subAssignments {
            InstUI.CollapsibleListRow(
                cell: StudentAssignmentListItemCell(model: model, isLastItem: nil, action: routeAction)
                    .identifier(identifier),
                isInitiallyExpanded: false
            ) {
                ForEach(subAssignments) { subItem in
                    StudentAssignmentListSubItemCell(model: subItem, action: routeAction)
                        .identifier(identifier, subItem.tag)
                }
            }
            InstUI.Divider(isLast: isLastItem)
        } else {
            StudentAssignmentListItemCell(model: model, isLastItem: isLastItem, action: routeAction)
                .identifier(identifier)
        }
    }

    private func navigateToDetails(at url: URL?) {
        viewModel.didSelectAssignment.send((url, controller))
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
    let viewModel = AssignmentListViewModel(state: .data, sections: sections)
    AssignmentListScreen(viewModel: viewModel)
}

#Preview("Empty State") {
    let emptyModel = AssignmentListViewModel(state: .empty)
    AssignmentListScreen(viewModel: emptyModel)
}

#Preview("Loading State") {
    let loadingModel = AssignmentListViewModel(state: .loading)
    AssignmentListScreen(viewModel: loadingModel)
}

#endif
