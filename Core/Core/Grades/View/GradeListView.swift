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

    // MARK: - Private properties

    @State private var isBaseOnGradedToggleOn = true
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(viewModel: GradeListViewModel) {
        self.viewModel = viewModel
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
                        dataView(data)
                    case .empty:
                        emptyView(width: width, height: height)
                    case .error:
                        errorView(width: width, height: height)
                    }
                }
            } refreshAction: { endRefreshing in
                viewModel.refresh(completion: endRefreshing)
            }
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
    private func dataView(_ gradeListData: GradeListData) -> some View {
        courseSummaryView(
            courseName: gradeListData.courseName ?? "",
            totalGrade: gradeListData.totalGradeText ?? NSLocalizedString("N/A", comment: "")
        )
        HStack {
            if !gradeListData.isGradingPeriodHidden {
                gradingPeriodMenu(
                    gradingPeriods: gradeListData.gradingPeriods,
                    currentGradingPeriod: gradeListData.currentGradingPeriod
                )
            }
            Spacer()
//            sortByMenu()
        }
        .frame(height: gradeListData.isGradingPeriodHidden ? 0 : 55)
        .padding(.horizontal, 16)
        .padding(.top, gradeListData.isGradingPeriodHidden ? 0 : -8)
        .padding(.bottom, 8)

        Divider()

        assignmentListView(
            assignmentSections: gradeListData.assignmentSections,
            userID: gradeListData.userID
        )
    }

    @ViewBuilder
    private func emptyView(width: CGFloat, height: CGFloat) -> some View {
        EmptyPanda(
            .Teacher,
            title: Text("No Courses", bundle: .core),
            message: Text(
                "It looks like assignments haven’t been created in this space yet.",
                bundle: .core
            )
        )
        .frame(minWidth: width, minHeight: height)
    }

    @ViewBuilder
    private func errorView(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Text("There was an error loading grades. Pull to refresh to try again.", bundle: .core)
                .font(.regular16).foregroundColor(.textDanger)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: width, minHeight: height)
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
            HStack {
                Text("Course", bundle: .core)
                    .foregroundStyle(Color.textDark)
                    .font(.regular14)
                Spacer()
                Text("Total", bundle: .core)
                    .foregroundStyle(Color.textDark)
                    .font(.regular14)
            }
            HStack {
                Text(courseName)
                    .foregroundStyle(Color.textDarkest)
                    .font(.semibold28)
                Spacer()
                Text(totalGrade)
                    .foregroundStyle(Color.textDarkest)
                    .font(.semibold28)
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private func togglesView() -> some View {
        VStack(spacing: 0) {
            HStack {
                Toggle(isOn: $isBaseOnGradedToggleOn) {
                    Text("Base on graded assignments", bundle: .core)
                        .foregroundStyle(Color.textDarkest)
                        .font(.regular16)
                        .fixedSize()
                        .lineLimit(1)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color(Brand.shared.primary)))
                .frame(height: 51)
            }
            .padding(.horizontal, 16)

            Divider()

            HStack {
                Toggle(isOn: $isBaseOnGradedToggleOn) {
                    Text("Show What-if Score", bundle: .core)
                        .foregroundStyle(Color.textDarkest)
                        .font(.regular16)
                        .fixedSize()
                        .lineLimit(1)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color(Brand.shared.primary)))
                .frame(height: 51)
            }
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
                Text("All", bundle: .core)
                    .foregroundStyle(Color(Brand.shared.primary))
                    .font(.regular16)
            }
            ForEach(gradingPeriods) { gradingPeriod in
                if let title = gradingPeriod.title {
                    Button {
                        viewModel.selectedGradingPeriod.accept(gradingPeriod)
                    } label: {
                        Text(title)
                            .foregroundStyle(Color(Brand.shared.primary))
                            .font(.regular16)
                    }
                }
            }
        } label: {
            Label(
                title: {
                    if let title = currentGradingPeriod?.title {
                        Text(title)
                    } else {
                        Text("All", bundle: .core)
                    }
                },
                icon: { Image.arrowOpenDownSolid.resizable().frame(width: 12, height: 12) }
            ).labelStyle(HorizontalRightAligned())
        }
    }

    @ViewBuilder
    private func sortByMenu() -> some View {
        Menu {
            Button {
                viewModel.sortByAscendingOrder.accept(true)
            } label: {
                Text("Ascending", bundle: .core)
            }
            Button {
                viewModel.sortByAscendingOrder.accept(false)
            } label: {
                Text("Descending", bundle: .core)
            }
        } label: {
            Label(
                title: {
                    Text("Sort By Due Date", bundle: .core)
                },
                icon: { Image.arrowOpenDownSolid.resizable().frame(width: 12, height: 12) }
            ).labelStyle(HorizontalRightAligned())
        }
    }

    @ViewBuilder
    private func assignmentListView(
        assignmentSections: [GradeListData.AssignmentSections],
        userID: String
    ) -> some View {
        ForEach(assignmentSections) { section in
            Section(header:
                HStack {
                    Text(section.title ?? "")
                        .foregroundStyle(Color.textDark)
                        .font(.regular14)
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
            ) {
                ForEach(section.assignments) { assignment in
                    GradeRowView(assignment: assignment, userID: userID)
                    Divider()
                }
            }
        }
    }
}

extension Assignment: Identifiable {}
extension GradingPeriod: Identifiable {}

struct HorizontalRightAligned: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 4) {
            configuration.title
            configuration.icon
        }
    }
}
