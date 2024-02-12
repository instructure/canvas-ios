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

import Combine
import SwiftUI

public struct GradeListView: View {
    // MARK: - Dependencies

    @ObservedObject private var viewModel: GradeListViewModel
    @ObservedObject private var offlineModeViewModel: OfflineModeViewModel
    @Environment(\.viewController) private var viewController

    // MARK: - Private properties

    @State private var isBaseOnGradedToggleOn = true
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    public init(
        viewModel: GradeListViewModel,
        offlineViewModel: OfflineModeViewModel = OfflineModeViewModel(interactor: OfflineModeAssembly.make())
    ) {
        self.viewModel = viewModel
        self.offlineModeViewModel = offlineViewModel
    }

    // MARK: - Components

    public var body: some View {
        GeometryReader { geometry in
            RefreshableScrollView {
                VStack(spacing: 0) {
                    let width = geometry.size.width
                    let height = geometry.size.height
                    switch viewModel.state {
                    case .loading:
                        loadingView(minWidth: width, minHeight: height)
                    case let .data(data):
                        dataView(
                            data,
                            isEmpty: false
                        )
                    case let .empty(data):
                        dataView(
                            data,
                            isEmpty: true
                        )
                    case .error:
                        errorView(width: width, height: height)
                    }
                }
            } refreshAction: { endRefreshing in
                viewModel.pullToRefreshDidTrigger.accept(endRefreshing)
            }
            .background(Color.backgroundLightest)
        }
        .navigationTitle(NSLocalizedString("Grades", comment: ""))
    }

    @ViewBuilder
    func loadingView(minWidth: CGFloat, minHeight: CGFloat) -> some View {
        ZStack {
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
        }
        .frame(minWidth: minWidth, minHeight: minHeight)
    }

    @ViewBuilder
    private func dataView(
        _ gradeListData: GradeListData,
        isEmpty: Bool
    ) -> some View {
        let verticalPadding: CGFloat = gradeListData.isGradingPeriodHidden && isEmpty ? 0 : 16
        courseSummaryView(
            courseName: gradeListData.courseName ?? "",
            totalGrade: gradeListData.totalGradeText ?? NSLocalizedString("N/A", comment: "")
        )
        HStack(spacing: 8) {
            if !gradeListData.isGradingPeriodHidden {
                gradingPeriodMenu(
                    gradingPeriods: gradeListData.gradingPeriods,
                    currentGradingPeriod: gradeListData.currentGradingPeriod
                )
                .disabled(offlineModeViewModel.isOffline)
                .opacity(offlineModeViewModel.isOffline ? 0.5 : 1)
            }
            Spacer()
            if !isEmpty {
                sortByMenu()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, verticalPadding)

        Divider()

        if isEmpty {
            emptyView().padding(.top, 16)
        } else {
            assignmentListView(
                assignmentSections: gradeListData.assignmentSections,
                userID: gradeListData.userID
            )
        }
    }

    @ViewBuilder
    private func emptyView() -> some View {
        Spacer()
        InteractivePanda(
            scene: SpacePanda(),
            title: String(localized: "No Assignments"),
            subtitle: String(localized: "It looks like assignments haven’t been created in this space yet.")
        )
        .padding(.horizontal, 16)
        Spacer()
    }

    @ViewBuilder
    private func errorView(width: CGFloat, height: CGFloat) -> some View {
        Spacer()
        InteractivePanda(
            scene: NoResultsPanda(),
            title: String(localized: "Something Went Wrong"),
            subtitle: String(localized: "Pull to refresh to try again.")
        )
        .padding(.horizontal, 16)
        .frame(minWidth: width, minHeight: height)
        Spacer()
    }

    @ViewBuilder
    private func courseSummaryView(
        courseName: String,
        totalGrade: String
    ) -> some View {
        VStack(spacing: 0) {
            courseDetailsView(
                courseName: courseName,
                totalGrade: totalGrade
            )
//            Divider()
//            togglesView()
        }
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.borderDark, lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func courseDetailsView(
        courseName: String,
        totalGrade: String
    ) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("Course", bundle: .core)
                    .foregroundStyle(Color.textDark)
                    .font(.regular14)
                    .accessibilityHidden(true)
                Spacer()
                Text("Total", bundle: .core)
                    .foregroundStyle(Color.textDark)
                    .font(.regular14)
                    .accessibilityHidden(true)
            }
            HStack(spacing: 4) {
                Text(courseName)
                    .foregroundStyle(Color.textDarkest)
                    .font(.semibold28)
                    .accessibilityLabel(Text("\(courseName) course"))
                Spacer()
                Text(totalGrade)
                    .foregroundStyle(Color.textDarkest)
                    .font(.semibold28)
                    .accessibilityLabel(Text("Total grade is \(totalGrade)", bundle: .core))
                    .accessibilityIdentifier("CourseTotalGrade")
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private func togglesView() -> some View {
        VStack(spacing: 0) {
            Toggle(isOn: $isBaseOnGradedToggleOn) {
                Text("Base on graded assignments", bundle: .core)
                    .foregroundStyle(Color.textDarkest)
                    .font(.regular16)
                    .fixedSize()
                    .lineLimit(1)
            }
            .toggleStyle(SwitchToggleStyle(tint: Color(Brand.shared.primary)))
            .frame(height: 51)
            .padding(.horizontal, 16)

            Divider()

            Toggle(isOn: $isBaseOnGradedToggleOn) {
                Text("Show What-if Score", bundle: .core)
                    .foregroundStyle(Color.textDarkest)
                    .font(.regular16)
                    .fixedSize()
                    .lineLimit(1)
            }
            .toggleStyle(SwitchToggleStyle(tint: Color(Brand.shared.primary)))
            .frame(height: 51)
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func gradingPeriodMenu(
        gradingPeriods: [GradingPeriod],
        currentGradingPeriod: GradingPeriod?
    ) -> some View {
        Menu {
            Button {
                viewModel.selectedGradingPeriod.accept(nil)
            } label: {
                gradingAndArrangeText(title: NSLocalizedString("All", comment: ""))
            }
            ForEach(gradingPeriods) { gradingPeriod in
                if let title = gradingPeriod.title {
                    Button {
                        viewModel.selectedGradingPeriod.accept(gradingPeriod)
                    } label: {
                        gradingAndArrangeText(title: title)
                    }
                }
            }
        } label: {
            Label(
                title: {
                    if let title = currentGradingPeriod?.title {
                        gradingAndArrangeText(title: title)
                    } else {
                        gradingAndArrangeText(title: NSLocalizedString("All", comment: ""))
                    }
                },
                icon: { Image.arrowOpenDownSolid.resizable().frame(width: 12, height: 12) }
            ).labelStyle(HorizontalRightAlignedLabelStyle())
        }
        .accessibilityRemoveTraits(.isButton)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func sortByMenu() -> some View {
        Menu {
            Button {
                viewModel.selectedGroupByOption.accept(.groupName)
            } label: {
                gradingAndArrangeText(title: NSLocalizedString("By Group", comment: ""))
            }
            Button {
                viewModel.selectedGroupByOption.accept(.dueDate)
            } label: {
                gradingAndArrangeText(title: NSLocalizedString("By Due Date", comment: ""))
            }
        } label: {
            Label(
                title: {
                    switch viewModel.selectedGroupByOption.value {
                    case .dueDate:
                        gradingAndArrangeText(title: NSLocalizedString("Arrange By Due Date", comment: ""))
                    case .groupName:
                        gradingAndArrangeText(title: NSLocalizedString("Arrange By Group", comment: ""))
                    }
                },
                icon: { Image.arrowOpenDownSolid.resizable().frame(width: 12, height: 12) }
            ).labelStyle(HorizontalRightAlignedLabelStyle())
        }
        .accessibilityRemoveTraits(.isButton)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func gradingAndArrangeText(title: String) -> some View {
        Text(title)
            .foregroundStyle(Color(Brand.shared.primary))
            .font(.regular16)
    }

    @ViewBuilder
    private func assignmentListView(
        assignmentSections: [GradeListData.AssignmentSections],
        userID: String
    ) -> some View {
        ForEach(assignmentSections) { section in
            Section(header:
                HStack(spacing: 0) {
                    Text(section.title ?? "")
                        .foregroundStyle(Color.textDark)
                        .font(.regular14)
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
            ) {
                ForEach(section.assignments) { assignment in
                    Button {
                        viewModel.didSelectAssignment.accept((viewController, assignment))
                    } label: {
                        VStack(spacing: 0) {
                            GradeRowView(assignment: assignment, userID: userID)
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

extension Assignment: Identifiable {}
extension GradingPeriod: Identifiable {}

#if DEBUG
struct GradeListViewPreview: PreviewProvider {
    static var previews: some View {
        GradeListView(
            viewModel: .init(
                interactor: GradeListInteractorPreview(),
                router: PreviewEnvironment.shared.router
            )
        )
    }
}

#endif
