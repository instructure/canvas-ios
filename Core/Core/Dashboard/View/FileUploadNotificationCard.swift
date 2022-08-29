//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

struct FileUploadNotificationCard: View {
    // MARK: - Dependencies

    @ObservedObject private var viewModel: FileUploadNotificationCardItemViewModel

    // MARK: - Init

    init(viewModel: FileUploadNotificationCardItemViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Button(action: viewModel.cardDidTap) {
            HStack(spacing: 16) {
                shareImage
                VStack(alignment: .leading, spacing: 0) {
                    uploadingSubmissionText
                    assignmentNameText
                    progressView
                }
                .accessibilityElement(children: .combine)
                .padding(.top, 14)
                .padding([.bottom, .trailing], 16)
            }
            .frame(minHeight: 58)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        Color(.electric),
                        lineWidth: 1
                    )
            )
        }
    }

    private var shareImage: some View {
        Color.electric
            .overlay(
                Image.share
                    .foregroundColor(Color.backgroundLightest)
                    .frame(width: 24, height: 24, alignment: .center)
            )
            .frame(width: 40, alignment: .center)
            .accessibilityHidden(true)
    }

    private var uploadingSubmissionText: some View {
        Text("Uploading submission")
            .font(.bold16)
            .foregroundColor(.textDarkest)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var assignmentNameText: some View {
        Text(viewModel.assignmentName)
            .font(.regular14)
            .foregroundColor(.textDark)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressView: some View {
        ProgressView(value: viewModel.progress)
            .foregroundColor(Color.electric)
            .background(Color.electric.opacity(0.2))
            .padding(.top, 8)
    }
}

struct FileUploadNotificationCard_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FileUploadNotificationCardItemViewModel(
            id: "1",
            assignmentName: "Test assignment",
            progress: 0.65,
            cardDidTap: {}
        )

        FileUploadNotificationCard(viewModel: viewModel)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
            .environment(\.sizeCategory, .extraSmall)

        FileUploadNotificationCard(viewModel: viewModel)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        FileUploadNotificationCard(viewModel: viewModel)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)

        FileUploadNotificationCard(viewModel: viewModel)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
