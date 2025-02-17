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
        @State var isShowSuccessModal: Bool = false
        @State var isShowConfirmModal: Bool = false

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
                headerIcon: Image.huiIcons.checkCircle,
                headerIconColor: Color.huiColors.icon.success,
                isShowCancelButton: false,
                confirmButton: .init(title: "View Submission") { print("Tapped") },
                isPresented: $isShowSuccessModal) { successModalContent }
        }

        private var successModalContent: some View {
            VStack(spacing: 15) {
                Text(verbatim: "We received your submission. You will be notified once it's been reviewed.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading) {
                    Text(verbatim: "Attempt X")
                    Text(verbatim: "confirmModalContent")
                    Text(verbatim: "Score: XX/XX")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .huiBorder(level: .level1, color: .gray, radius: 12)
            }
        }

        private var confirmModalContent: some View {
            Text(verbatim: "You are submitting a text-based attempt. Any uploaded files will be deleted upon submission. Once you submit this attempt, you won’t be able to make any changes.")
        }
    }
}

#Preview {
    HorizonUI.Modal<EmptyView>.Storybook()
}
