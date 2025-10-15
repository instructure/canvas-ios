//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct GradeListHeaderView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @ObservedObject var viewModel: GradeListViewModel
    let toggleViewIsVisible: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                gradeDetailsView
                if viewModel.isParentApp {
                    LegacyGradeListFilterButton(viewModel: viewModel)
                        .paddingStyle(.leading, .standard)
                }
            }
            .padding([.horizontal, .top], 16)
            .padding(.bottom, 10)
            .background(.backgroundLight)
            .overlay(alignment: .bottom) {
                if !toggleViewIsVisible {
                    InstUI.Divider()
                }
            }
        }
    }

    @ViewBuilder
    private var gradeDetailsView: some View {
        HStack {
            totalLabelText
                .frame(maxWidth: .infinity, alignment: .leading)
            if let totalGrade = viewModel.totalGradeText {
                Text(totalGrade)
                    .foregroundStyle(Color.textDarkest)
                    .font(.semibold22)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel(Text("Total grade is \(totalGrade)", bundle: .core))
                    .accessibilityIdentifier("CourseTotalGrade")
            } else {
                Image(uiImage: .lockLine)
                    .size(16)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier("lockIcon")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, verticalSizeClass == .regular ? 20 : 5)
        .background(
            Color.backgroundLightest
                .cornerRadius(6)
        )
        .shadow(color: Color.textDark.opacity(0.2), radius: 5, x: 0, y: 0)
    }

    @ViewBuilder
    private var totalLabelText: some View {
        let isShowGradeAssignment = !toggleViewIsVisible &&
        viewModel.baseOnGradedAssignment &&
        viewModel.totalGradeText != nil

        let totalText = String(localized: "Total", bundle: .core)
        let restrictedText = String(localized: "Total grades are restricted", bundle: .core)
        let gradedAssignmentsText = String(localized: "Based on graded assignments", bundle: .core)
        let text = isShowGradeAssignment ? gradedAssignmentsText : totalText
        Text(viewModel.totalGradeText == nil ? restrictedText : text)
            .foregroundStyle(Color.textDark)
            .font(.regular14)
            .accessibilityHidden(true)
            .animation(.smooth, value: isShowGradeAssignment)
            .lineLimit(1)
    }
}
