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

import Core
import HorizonUI
import SwiftUI

struct HCreateMessageView: View {

    @Environment(\.viewController) private var viewController
    @Bindable var viewModel: HCreateMessageViewModel
    @FocusState private var isBodyFocused: Bool
    @FocusState private var isSubjectFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            header
            bodyContent
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Private

    private var bodyContent: some View {
        AttachmentView(viewModel: viewModel.attachmentViewModel) {
            ScrollView {
                VStack(alignment: .leading, spacing: .huiSpaces.space12) {
                    courseSelection
                    peopleSelection
                    messageTitleInput
                    messageBodyInput
                    fileAttachmentButtonRow
                    fileAttachments
                    Spacer()
                }
                .padding(.horizontal, .huiSpaces.space24)
                .padding(.top, .huiSpaces.space12)
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .onTapGesture {
                ScrollOffsetReader.dismissKeyboard()
            }
        }
    }

    private var courseSelection: some View {
        HorizonUI.SingleSelect(
            selection: $viewModel.selectedCourse,
            focused: $viewModel.isCourseFocused,
            options: viewModel.courses,
            disabled: viewModel.isCourseSelectionDisabled,
            placeholder: String(localized: "Select a course", bundle: .horizon),
            zIndex: 102
        )
    }

    private var fileAttachmentButtonRow: some View {
        HStack(spacing: .huiSpaces.space8) {
            HorizonUI.icons.attachFile
                .foregroundStyle(HorizonUI.colors.icon.default)
            Text(String(localized: "Attach file", bundle: .horizon))
                .huiTypography(.buttonTextLarge)
                .foregroundStyle(HorizonUI.colors.text.title)
            Spacer()
        }
        .onTapGesture { viewModel.attachFile(from: viewController) }
        .opacity(viewModel.attachmentButtonOpacity)
    }

    private var fileAttachments: some View {
        VStack(spacing: .huiSpaces.space8) {
            ForEach(viewModel.attachmentItems) { attachment in
                HorizonUI.UploadedFile(
                    fileName: attachment.filename,
                    actionType: attachment.actionType
                ) {
                    attachment.delete()
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: .huiSpaces.space8) {
            Spacer()
            footerCancelButton
                .opacity(viewModel.cancelButtonOpacity)
            ZStack(alignment: .center) {
                HorizonUI.Spinner(size: .xSmall)
                    .opacity(viewModel.spinnerOpacity)
                footerSendButton
                    .opacity(viewModel.sendButtonOpacity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .huiSpaces.space12)
        .padding(.horizontal, .huiSpaces.space24)
        .overlay(
            divider,
            alignment: .top
        )
    }

    private var footerCancelButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Cancel", bundle: .horizon),
            type: .white
        ) {
            viewModel.close(viewController: viewController)
        }
        .disabled(viewModel.isCloseDisabled)
    }

    private var footerSendButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Send", bundle: .horizon),
            type: .institution
        ) {
            viewModel.sendMessage(viewController: viewController)
        }
        .disabled(viewModel.isSendDisabled)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.huiColors.surface.divider)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }

    private var header: some View {
        HStack(spacing: .zero) {
            Text("Create Message")
                .huiTypography(.h2)
            Spacer()
            HorizonUI.IconButton(
                HorizonUI.icons.close,
                type: .white,
                isSmall: true
            ) {
                viewModel.close(viewController: viewController)
            }
            .disabled(viewModel.isCloseDisabled)
        }
        .frame(height: 88)
        .padding(.horizontal, .huiSpaces.space24)
        .overlay(
            divider,
            alignment: .bottom
        )
    }

    private var messageBodyInput: some View {
        HorizonUI.TextArea(
            $viewModel.body,
            placeholder: String(localized: "Message", bundle: .horizon),
            disabled: viewModel.isBodyDisabled,
            focused: _isBodyFocused
        )
        .frame(height: 144)
        .onChange(of: isBodyFocused) { _, _ in
            viewModel.bodyFocusedChange(isFocused: isBodyFocused)
        }
    }

    private var messageTitleInput: some View {
        HorizonUI.TextInput(
            $viewModel.subject,
            placeholder: String(localized: "Title/Subject", bundle: .horizon),
            disabled: viewModel.isSubjectDisabled,
            focused: _isSubjectFocused
        )
        .onChange(of: isSubjectFocused) { _, _ in
            viewModel.subjectFocusedChange(isFocused: isSubjectFocused)
        }
    }

    private var peopleSelection: some View {
        RecipientSelectionView(
            viewModel: viewModel.peopleSelectionViewModel,
            placeholder: String(localized: "Recipients", bundle: .horizon),
            disabled: viewModel.isPeopleSelectionDisabled
        )
    }
}

#if DEBUG
#Preview {
    HCreateMessageView(
        viewModel: .init(
            composeMessageInteractor: ComposeMessageInteractorPreview()
        )
    )
}
#endif
