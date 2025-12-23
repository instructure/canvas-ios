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
    // MARK: - Propertites a11y

    @AccessibilityFocusState private var focusedFilterCourse: Bool?
    @AccessibilityFocusState private var focusedFilterPeople: Bool?
    @AccessibilityFocusState private var focusedAttachedFile: Bool?

    @Environment(\.viewController) private var viewController
    @Bindable var viewModel: HCreateMessageViewModel
    @FocusState private var isBodyFocused: Bool
    @FocusState private var isSubjectFocused: Bool
    @State private var isRecipientFocused: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            header
                .onTapGesture {
                    isBodyFocused = false
                    isRecipientFocused = false
                    isSubjectFocused = false
                }
            bodyContent

            if isFooterVisiable {
                footer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Private

    private var isFooterVisiable: Bool {
        !viewModel.isCourseFocused
        && !isSubjectFocused
        && !viewModel.isCourseFocused
        && !isRecipientFocused
        && !isBodyFocused
    }

    private var bodyContent: some View {
        AttachmentView(viewModel: viewModel.attachmentViewModel) {
            ScrollView {
                VStack(alignment: .leading, spacing: .huiSpaces.space8) {
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
            .scrollDismissesKeyboard(.immediately)
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .onTapGesture {
                ScrollOffsetReader.dismissKeyboard()
            }
        }
        .onReceive(viewModel.recipientSelectionViewModel.isFocusedSubject) { value in
            isRecipientFocused = value
        }
        .onChange(of: viewModel.attachmentViewModel.isPickerVisible) { _, newValue in
            if newValue == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    focusedAttachedFile = true
                }
            }
        }
    }

    private var courseSelection: some View {
        HorizonUI.SingleSelect(
            selection: $viewModel.selectedCourse,
            focused: $viewModel.isCourseFocused,
            isSearchable: false,
            label: nil,
            options: viewModel.courses,
            disabled: viewModel.isCourseSelectionDisabled,
            zIndex: 102
        )
        .id(viewModel.courses.count)
        .accessibilityFocused($focusedFilterCourse, equals: true)
        .onChange(of: viewModel.isCourseFocused) { _, newValue in
            if newValue == false {
                focusedFilterCourse = true
            }
        }
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
        .contentShape(.rect)
        .onTapGesture { viewModel.attachFile(from: viewController) }
        .opacity(viewModel.attachmentButtonOpacity)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(String(localized: "Attach file"))
        .accessibilityFocused($focusedAttachedFile, equals: true)
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
                .accessibilityElement(children: .ignore)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(String(format: "File name is %@. ", attachment.filename))
                .accessibilityHint(String(localized: "Double tap to delete"))
                .accessibilityAction {
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
        .accessibilityAddTraits(.isButton)
    }

    private var footerSendButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Send", bundle: .horizon),
            type: .institution
        ) {
            viewModel.sendMessage(viewController: viewController)
        }
        .disabled(viewModel.isSendDisabled)
        .accessibilityAddTraits(.isButton)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.huiColors.surface.divider)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }

    private var header: some View {
        HStack(spacing: .zero) {
            Text("Create message")
                .huiTypography(.h2)
                .accessibilityAddTraits(.isHeader)
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
        .focused($isBodyFocused)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            String.localizedStringWithFormat(
                String(localized: "Your Message is %@", bundle: .horizon),
                viewModel.body.isEmpty ? String(localized: "Empty.") : viewModel.body
            ))
        .accessibilityHint(String(localized: "Doubel Tap to start typing."))
        .accessibilityAction {
            isBodyFocused = true
        }
        .accessibilityRemoveTraits(.isButton)
    }

    private var messageTitleInput: some View {
        HorizonUI.TextInput(
            $viewModel.subject,
            placeholder: String(localized: "Title/subject", bundle: .horizon),
            disabled: viewModel.isSubjectDisabled,
            focused: _isSubjectFocused,
            characterLimit: 255
        )
        .onChange(of: isSubjectFocused) { _, _ in
            viewModel.subjectFocusedChange(isFocused: isSubjectFocused)
        }
    }

    private var peopleSelection: some View {
        RecipientSelectionView(
            viewModel: viewModel.recipientSelectionViewModel,
            placeholder: String(localized: "Recipients", bundle: .horizon),
            disabled: viewModel.isPeopleSelectionDisabled
        )
        .onChange(of: viewModel.recipientSelectionViewModel.isFocusedSubject.value) { _, newValue in
            if newValue == false {
                focusedFilterPeople = true
            }
        }
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
