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

public extension HorizonUI {
    struct ProgramCard: View {
        // MARK: - Dependencies

        private let courseName: String
        private let isSelfEnrolled: Bool
        private let isRequired: Bool
        @Binding private var isLoading: Bool
        private let estimatedTime: String?
        private let dueDate: String?
        private let status: ProgramCard.Status
        private let onTapEnroll: () -> Void

        // MARK: - Private Propertites

        private let cornerRadius: CornerRadius = .level3

        // MARK: - Init

        public init(
            courseName: String,
            isSelfEnrolled: Bool,
            isRequired: Bool,
            isLoading: Binding<Bool>,
            estimatedTime: String?,
            dueDate: String?,
            status: ProgramCard.Status,
            onTapEnroll: @escaping () -> Void
        ) {
            self.courseName = courseName
            self.isSelfEnrolled = isSelfEnrolled
            self.isRequired = isRequired
            _isLoading = isLoading
            self.estimatedTime = estimatedTime
            self.dueDate = dueDate
            self.status = status
            self.onTapEnroll = onTapEnroll
        }

        public var body: some View {
            VStack(alignment: .leading, spacing: .huiSpaces.space16) {
                titleText
                if case let .inProgress(completionPercent) = status {
                    progressBar(value: completionPercent)
                }
                statusPills
                if status.isActive {
                    enrollButton
                }
            }
            .padding(.huiSpaces.space16)
            .background {
                if isRequired {
                    RoundedRectangle(cornerRadius: cornerRadius.attributes.radius)
                        .stroke(status.borderColor, lineWidth: 1)
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius.attributes.radius)
                        .stroke(Color.huiColors.lineAndBorders.containerStroke, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                }
            }
            .background(Color.huiColors.surface.cardPrimary.cornerRadius(cornerRadius.attributes.radius))
        }

        private var titleText: some View {
            HStack(alignment: .top, spacing: .huiSpaces.space4) {
                if status.isCompleted {
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

        private func progressBar(value: Double) -> some View {
            VStack(alignment: .leading, spacing: .huiSpaces.space8) {
                HStack(spacing: .huiSpaces.space2) {
                    let percentageRound = round(value * 100.0)
                    Group {
                        Text(percentageRound, format: .number) + Text("%")
                    }
                    Text("complete")
                }
                .huiTypography(.p2)
                .foregroundStyle(Color.huiColors.surface.institution)
                HorizonUI.ProgressBar(
                    progress: value,
                    size: .small,
                    numberPosition: .hidden
                )
            }
        }

        private var statusPills: some View {
            HorizonUI.ProgramCard.Pills(
                isEnrolled: status.isEnrolled && isSelfEnrolled,
                isRequired: isRequired,
                status: status,
                estimatedTime: estimatedTime,
                dueDate: dueDate
            )
        }

        @ViewBuilder
        private var enrollButton: some View {
            if !status.isEnrolled, isSelfEnrolled {
                HStack {
                    Spacer()
                    HorizonUI.LoadingButton(
                        title: String(localized: "Enroll"),
                        type: .institution,
                        fillsWidth: false,
                        isLoading: $isLoading) {
                            onTapEnroll()
                        }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isLoading: Bool = false
    ScrollView {
        VStack {
            HorizonUI.ProgramCard(
                courseName: "Course Name Dolor Sit Amet",
                isSelfEnrolled: true,
                isRequired: true,
                isLoading: $isLoading,
                estimatedTime: "10 Hours",
                dueDate: "10-10-2020",
                status: .active
            ) { isLoading.toggle() }

            HorizonUI.ProgramCard(
                courseName: "Course Name Dolor Sit Amet",
                isSelfEnrolled: false,
                isRequired: true,
                isLoading: $isLoading,
                estimatedTime: "10 Hours",
                dueDate: "10-10-2020",
                status: .active
            ) { isLoading.toggle() }

            HorizonUI.ProgramCard(
                courseName: "Course Name Dolor Sit Amet",
                isSelfEnrolled: false,
                isRequired: false,
                isLoading: $isLoading,
                estimatedTime: "10 Hours",
                dueDate: "10-10-2020",
                status: .active
            ) { isLoading.toggle() }

            HorizonUI.ProgramCard(
                courseName: "Course Name Dolor Sit Amet",
                isSelfEnrolled: true,
                isRequired: true,
                isLoading: $isLoading,
                estimatedTime: "10 Hours",
                dueDate: "10-10-2020",
                status: .active
            ) { isLoading.toggle() }

            HorizonUI.ProgramCard(
                courseName: "Course Name Dolor Sit Amet",
                isSelfEnrolled: true,
                isRequired: true,
                isLoading: $isLoading,
                estimatedTime: "10 Hours",
                dueDate: "10-10-2020",
                status: .inProgress(completionPercent: 0.5)
            ) { isLoading.toggle() }

            HorizonUI.ProgramCard(
                courseName: "Course Name Dolor Sit Amet",
                isSelfEnrolled: true,
                isRequired: true,
                isLoading: $isLoading,
                estimatedTime: "10 Hours",
                dueDate: "10-10-2020",
                status: .locked
            ) { isLoading.toggle() }

            HorizonUI.ProgramCard(
                courseName: "Course Name Dolor Sit Amet",
                isSelfEnrolled: true,
                isRequired: true,
                isLoading: $isLoading,
                estimatedTime: "10 Hours",
                dueDate: "10-10-2020",
                status: .completed
            ) { isLoading.toggle() }
        }
        .padding()
    }
}
