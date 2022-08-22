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
        HStack(spacing: 16) {
            Color.electric
                .overlay(
                    Image.share
                        .foregroundColor(Color.backgroundLightest)
                        .frame(width: 24, height: 24, alignment: .center)
                )
                .frame(width: 48, alignment: .center)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                Text("Uploading submission")
                    .font(.regular16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(viewModel.assignmentName)
                    .font(.regular14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ProgressView(value: viewModel.progress)
                    .foregroundColor(Color(Brand.shared.primary))
                    .background(Color(Brand.shared.primary).opacity(0.2))
            }
            .accessibilityElement(children: .combine)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .padding(.trailing, 12)
        }
        .frame(minHeight: 58)
        .border(
            Color.electric,
            width: 2
        )
        .cornerRadius(4)
        .onTapGesture {
            viewModel.cardDidTap()
        }
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
