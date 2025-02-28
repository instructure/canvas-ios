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

public extension HorizonUI.Modal {
    struct Storybook: View {
        @State private var isShowSuccessModal: Bool = false
        @State private var isShowConfirmModal: Bool = false

        public var body: some View {
            VStack(spacing: 24)  {
                Button("Show Success Modal") {
                    isShowSuccessModal.toggle()
                }

                Button("Show Confirm Modal") {
                    isShowConfirmModal.toggle()
                }
            }
            .huiModal(
                headerTitle: "Confirm Submission",
                confirmButton: .init(title: "Submit Attempt") { print("Submit Attempt") },
                isPresented: $isShowConfirmModal) { confirmModalContent}
            .huiModal(
                headerTitle: "Assignment Successfully Submitted!",
                headerIcon: Image.huiIcons.checkCircleFull,
                headerIconColor: Color.huiColors.icon.success,
                isShowCancelButton: false,
                confirmButton: .init(title: "View Submission") { print("Tapped") },
                isPresented: $isShowSuccessModal) { successModalContent }
        }

        private var successModalContent: some View {
            VStack(spacing: .huiSpaces.space24) {
                Text(verbatim: "We received your submission. You will be notified once it's been reviewed.")
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                assignmentInfo
            }
        }

        private var assignmentInfo: some View {
            VStack(spacing: .huiSpaces.space12) {
                attemptView
                Text(verbatim: "Mon XX at XX:XX AM")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.huiColors.text.timestamp)
                    .huiTypography(.p2)
                scoreView
            }
            .padding(.huiSpaces.space16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.huiColors.surface.pageSecondary)
                    .huiBorder(level: .level1,
                               color: Color.huiColors.lineAndBorders.lineStroke,
                               radius: 16)
            }
        }

        private var attemptView: some View {
            HStack(spacing: .huiSpaces.space2) {
                Text(verbatim: "Attempt")
                Text(verbatim: "10")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.p2)
        }

        @ViewBuilder
        private var scoreView: some View {
            HStack(spacing: .huiSpaces.space2) {
                Text(verbatim: "Score")
                Text(verbatim: "80/100")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.p2)
        }


        private var confirmModalContent: some View {
            Text(verbatim: "You are submitting a text-based attempt. Any uploaded files will be deleted upon submission. Once you submit this attempt, you won’t be able to make any changes.")
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
        }
    }
}

#Preview {
    HorizonUI.Modal<EmptyView>.Storybook()
}
