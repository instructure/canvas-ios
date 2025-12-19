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
import HorizonUI

struct ProgramCardView: View {
    // MARK: - Dependencies

    private let programCourse: ProgramCourse
    private let status: ProgramCardStatus
    private let isLinear: Bool
    @Binding private var isLoading: Bool
    private let onTapEnroll: () -> Void

    // MARK: - UI
    private let cornerRadius: HorizonUI.CornerRadius = .level3

    // MARK: - Init
    public init(
        programCourse: ProgramCourse,
        isLinear: Bool,
        status: ProgramCardStatus,
        isLoading: Binding<Bool>,
        onTapEnroll: @escaping () -> Void
    ) {
        self.programCourse = programCourse
        self.isLinear = isLinear
        self.status = status
        _isLoading = isLoading
        self.onTapEnroll = onTapEnroll
    }

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            VStack(alignment: .leading, spacing: .huiSpaces.space16) {
                titleView
                statusView
            }
           .accessibilityElement(children: .ignore)
           .accessibilityLabel(programCourse.accessibilityLabelText(status: status, isLinear: isLinear))
           .accessibilityHint(programCourse.accessibilityHintString(status: status))
            if status == .notEnrolled {
                enrollButton
            }
        }
        .padding(.huiSpaces.space16)
        .background(cardBackground)
    }
    // MARK: - Components
    private var titleView: some View {
        HStack(alignment: .top, spacing: .huiSpaces.space4) {
            if status == .completed {
                Image.huiIcons.checkCircleFull
                    .foregroundStyle(status.borderColor)
            }
            Text(programCourse.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(status.forgroundColor)
                .huiTypography(.h4)
        }
    }

    private var statusView: some View {
        ProgramCardStatusView(
            isEnrolled: status.isEnrolled && programCourse.isSelfEnrolled,
            isRequired: programCourse.isRequired,
            isLinear: isLinear,
            status: status,
            estimatedTime: programCourse.estimatedTime,
            completionPercent: programCourse.completionPercent
        )
    }

    @ViewBuilder
    private var enrollButton: some View {
        HStack {
            Spacer()
            HorizonUI.LoadingButton(
                title: String(localized: "Enroll"),
                type: .institution,
                fillsWidth: false,
                isLoading: $isLoading,
                onSave: onTapEnroll
            )
        }
        .accessibilityLabel(String(localized: "Enroll to the course"))
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius.attributes.radius)
                .fill(Color.huiColors.surface.cardPrimary)
            borderView
        }
    }

    @ViewBuilder
    private var borderView: some View {
        if programCourse.isRequired || status == .completed {
            RoundedRectangle(cornerRadius: cornerRadius.attributes.radius)
                .stroke(status.borderColor, lineWidth: 1)
        } else {
            RoundedRectangle(cornerRadius: cornerRadius.attributes.radius)
                .stroke(
                    Color.huiColors.lineAndBorders.containerStroke,
                    style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                )
        }
    }
}

#Preview {
    @Previewable @State var isLoading: Bool = false
    ProgramCardView(
        programCourse: ProgramCourse(
            id: "12",
            name: "Course Name Dolor Sit Amet",
            isSelfEnrolled: true,
            isRequired: true,
            status: "Required",
            progressID: "progressID",
            completionPercent: 0.1,
            moduleItemsestimatedTime: [],
            index: 1
        ),
        isLinear: true,
        status: .active,
        isLoading: $isLoading) { isLoading.toggle() }
}
