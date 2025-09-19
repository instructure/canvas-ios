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
    // MARK: - Content
    private let courseName: String
    private let isLinear: Bool
    private let isSelfEnrolled: Bool
    private let isRequired: Bool
    private let estimatedTime: String?
    private let courseStatus: String
    private let completionPercent: Double

    // MARK: - State
    @Binding private var isLoading: Bool

    // MARK: - Actions
    private let onTapEnroll: () -> Void

    // MARK: - UI
    private let cornerRadius: HorizonUI.CornerRadius = .level3
    private var status: ProgramCardStatus {
        .init(completionPercent: completionPercent, status: courseStatus)
    }

    // MARK: - Init
    public init(
        courseName: String,
        isLinear: Bool,
        isSelfEnrolled: Bool,
        isRequired: Bool,
        isLoading: Binding<Bool>,
        estimatedTime: String?,
        courseStatus: String,
        completionPercent: Double,
        onTapEnroll: @escaping () -> Void
    ) {
        self.courseName = courseName
        self.isLinear = isLinear
        self.isSelfEnrolled = isSelfEnrolled
        self.isRequired = isRequired
        _isLoading = isLoading
        self.estimatedTime = estimatedTime
        self.courseStatus = courseStatus
        self.completionPercent = completionPercent
        self.onTapEnroll = onTapEnroll
    }

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            titleView
            statusView
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
            Text(courseName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(status.forgroundColor)
                .huiTypography(.h4)
        }
    }

    private var statusView: some View {
        ProgramCardStatusView(
            isEnrolled: status.isEnrolled && isSelfEnrolled,
            isRequired: isRequired,
            isLinear: isLinear,
            status: status,
            estimatedTime: estimatedTime,
            completionPercent: completionPercent
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
        if isRequired || status == .completed {
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
        courseName: "Course Name Dolor Sit Amet",
        isLinear: true,
        isSelfEnrolled: true,
        isRequired: true,
        isLoading: $isLoading,
        estimatedTime: "10 Hours",
        courseStatus: "ENROLLED",
        completionPercent: 0.3

    ) { isLoading.toggle() }
}
