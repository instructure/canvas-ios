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
    @Environment(\.viewController) var viewController

    // MARK: - Init

    init(viewModel: FileUploadNotificationCardItemViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        // TODO: Routing to a fully functional `FileProgressListView` will be possible once
        // the new File Upload logic is used everywhere in the app.
        /*
         Button {
             viewModel.cardDidTap(
                 viewModel.id,
                 viewController
             )
         } label: {
         */
        HStack(spacing: 16) {
            shareImage
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    submissionStateText
                    closeButton
                }
                assignmentNameText
                if case .uploading = viewModel.state {
                    progressView
                }
            }
            .accessibilityElement(children: .contain)
            .padding(.top, 14)
            .padding([.bottom, .trailing], 16)
        }
        .frame(minHeight: 58)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    viewModel.state.color,
                    lineWidth: 1
                )
        )
//        }
    }

    private var shareImage: some View {
        viewModel.state.color
            .overlay(
                viewModel.state.image
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24, alignment: .center)
            )
            .frame(width: 40, alignment: .center)
            .accessibilityHidden(true)
    }

    private var submissionStateText: some View {
        Text(viewModel.state.text)
            .font(.bold16, lineHeight: .fit)
            .foregroundColor(.textDarkest)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibility(sortPriority: 2)
    }

    private var closeButton: some View {
        Button {
            viewModel.hideDidTap()
        } label: {
            Image.xLine
                .frame(width: 24, height: 24)
                .foregroundColor(Color.textDarkest)
                .offset(x: 0, y: -4)
        }
        .accessibility(sortPriority: 0)
        .accessibilityLabel(Text("Hide", bundle: .core))
    }

    private var assignmentNameText: some View {
        Text(viewModel.assignmentName)
            .font(.regular14)
            .foregroundColor(.textDark)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibility(sortPriority: 1)
    }

    private var progressView: some View {
        ProgressView()
            .progressViewStyle(
                .indeterminateBar(
                    foregroundColor: .electric,
                    backgroundColor: .electric.opacity(0.2)
                )
            )
            .padding(.top, 8)
    }
}

#if DEBUG
    struct FileUploadNotificationCard_Previews: PreviewProvider {
        static var previews: some View {
            FileUploadNotificationCard(viewModel: createViewModel(state: .uploading))
                .preferredColorScheme(.light)
                .previewLayout(.fixed(width: 450, height: 65))

            FileUploadNotificationCard(viewModel: createViewModel(state: .uploading))
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 450, height: 65))

            FileUploadNotificationCard(viewModel: createViewModel(state: .success))
                .preferredColorScheme(.light)
                .previewLayout(.fixed(width: 450, height: 65))

            FileUploadNotificationCard(viewModel: createViewModel(state: .success))
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 450, height: 65))

            FileUploadNotificationCard(viewModel: createViewModel(state: .failure))
                .preferredColorScheme(.light)
                .previewLayout(.fixed(width: 450, height: 65))

            FileUploadNotificationCard(viewModel: createViewModel(state: .failure))
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 450, height: 65))
        }

        private static func createViewModel(
            state: FileUploadNotificationCardItemViewModel.State
        ) -> FileUploadNotificationCardItemViewModel {
            let env = PreviewEnvironment()
            let context = env.globalDatabase.viewContext
            let submission: FileSubmission = context.insert()

            return FileUploadNotificationCardItemViewModel(
                id: submission.objectID,
                assignmentName: "Test assignment",
                state: state,
                isHiddenByUser: false,
                cardDidTap: { _, _ in },
                dismissDidTap: {}
            )
        }
    }
#endif
