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

struct CreateMessageView: View {

    @Environment(\.viewController) private var viewController
    @Bindable var viewModel: CreateMessageViewModel

    var body: some View {
        VStack(alignment: .leading) {
            header
            bodyContent
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fileImporter(
            isPresented: $viewModel.isFilePickerVisible,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                viewModel.addFiles(urls: urls)
            case .failure:
                break
            }
        }
        .sheet(isPresented: $viewModel.isImagePickerVisible) {
            ImagePickerViewController(
                sourceType: .photoLibrary,
                imageHandler: viewModel.addFile
            )
        }
        .sheet(isPresented: $viewModel.isTakePhotoVisible) {
            ImagePickerViewController(
                sourceType: .camera,
                imageHandler: viewModel.addFile
            )
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $viewModel.isAudioRecordVisible) {
            AttachmentPickerAssembly.makeAudioPickerViewcontroller(
                router: viewModel.router,
                onSelect: viewModel.addFile
            )
            .interactiveDismissDisabled()
        }
    }

    // MARK: - Private

    private var bodyContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .huiSpaces.space12) {
                peopleSelection
                individualMessageCheckbox
                messageTitleInput
                messageBodyInput
                fileAttachmentButtonRow
                fileAttachments
                Spacer()
            }
            .padding(.top, .huiSpaces.space12)
        }
        .padding(.horizontal, .huiSpaces.space24)
        .frame(maxHeight: .infinity, alignment: .topLeading)
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
        .onTapGesture { viewModel.attachFile(viewController: viewController) }
        .opacity(viewModel.attachmentButtonOpacity)
    }

    private var fileAttachments: some View {
        VStack(spacing: .huiSpaces.space8) {
            ForEach(viewModel.attachmentViewModels) { attachment in
                FileAttachment(viewModel: attachment)
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
        .frame(height: 92)
        .frame(maxWidth: .infinity)
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

    private var individualMessageCheckbox: some View {
        HorizonUI.Controls.Checkbox(
            isOn: $viewModel.isIndividualMessage,
            title: String(localized: "Send individual messages to each recipient"),
            isDisabled: viewModel.isCheckboxDisbled
        )
    }

    private var header: some View {
        HStack {
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
            disabled: viewModel.isBodyDisabled
        )
        .frame(height: 144)
    }

    private var messageTitleInput: some View {
        HorizonUI.TextInput(
            $viewModel.subject,
            placeholder: String(localized: "Title/Subject", bundle: .horizon),
            disabled: viewModel.isSubjectDisabled
        )
    }

    private var peopleSelection: some View {
        PeopleSelectionView(
            viewModel: viewModel.peopleSelectionViewModel,
            disabled: viewModel.isPeopleSelectionDisabled
        )
    }
}

struct FileAttachment: View {
    var viewModel: AttachmentViewModel

    var body: some View {
        HStack {
            ZStack {
                spinner
                checkbox
            }
            title
            Spacer()
            ZStack {
                cancelButton
                deleteButton
            }
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, HorizonUI.spaces.space16)
        .padding(.vertical, HorizonUI.spaces.space8)
        .cornerRadius(HorizonUI.spaces.space16)
        .overlay(
            RoundedRectangle(cornerRadius: HorizonUI.spaces.space16)
                .stroke(Color.huiColors.lineAndBorders.lineStroke, lineWidth: 1)
        )
        .padding(1)
    }

    private var cancelButton: some View {
        HorizonUI.IconButton(
            HorizonUI.icons.close,
            type: .white,
            isSmall: true
        ) {
            viewModel.cancel()
        }
        .opacity(viewModel.cancelOpacity)
    }

    private var checkbox: some View {
        HorizonUI.icons.checkCircleFull
            .foregroundStyle(Color.huiColors.icon.success)
            .opacity(viewModel.checkmarkOpacity)
    }

    private var deleteButton: some View {
        HorizonUI.IconButton(
            HorizonUI.icons.delete,
            type: .white,
            isSmall: true
        ) {
            viewModel.delete()
        }
        .opacity(viewModel.deleteOpacity)
    }

    private var spinner: some View {
        HorizonUI.Spinner(size: .xSmall)
            .opacity(viewModel.spinnerOpacity)
            .frame(width: 24, height: 24)
    }

    private var title: some View {
        Text(viewModel.filename)
            .huiTypography(.p1)
    }
}

#Preview {
    CreateMessageView(
        viewModel: .init(
            composeMessageInteractor: ComposeMessageInteractorPreview()
        )
    )
}
