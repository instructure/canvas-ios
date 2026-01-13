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

import HorizonUI
import SwiftUI

struct InboxMessageRowView: View {
    let message: HInboxMessageModel
    @Bindable var viewModel: HMessageDetailsViewModel
    @Environment(\.viewController) private var viewController
    var body: some View {
        VStack(alignment: .leading, spacing: HorizonUI.spaces.space8) {
            VStack(alignment: .leading, spacing: HorizonUI.spaces.space8) {
                messageInfoView
                Text(message.body)
                    .foregroundStyle(HorizonUI.colors.text.body)
                    .huiTypography(.p1)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(message.accessibilityLabel)
            if message.attachments.isNotEmpty {
                VStack(spacing: HorizonUI.spaces.space8) {
                    attachmentsView
                }
                .padding(.top, HorizonUI.spaces.space8)
            }
        }
        .padding(.vertical, HorizonUI.spaces.space16)
        .overlay(
            Rectangle()
                .fill(viewModel.messages.last == message ? .clear : Color.huiColors.lineAndBorders.lineStroke)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    var messageInfoView: some View {
        HStack(spacing: .zero) {
            Text(message.author)
                .huiTypography(.labelLargeBold)
            Spacer()
            Text(message.date)
                .huiTypography(.p3)
                .foregroundStyle(HorizonUI.colors.text.timestamp)
        }
    }

    var attachmentsView: some View {
        ForEach(message.attachments) { attachment in
            HorizonUI.UploadedFile(
                fileName: attachment.filename,
                actionType: attachment.downloadState
            ) {
                action(attachment: attachment)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(format: String(localized: "File name is %@"), attachment.filename))
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(attachment.isUploading ? String(localized: "Double tap to cancel download. ") : String(localized: "Double tap to download. "))
            .accessibilityAction {
                action(attachment: attachment)
            }
        }
    }

    private func action(attachment: AttachmentFileModel) {
        if attachment.downloadState == .loading {
            viewModel.cancelDownload(messageID: message.id, attachment: attachment)
        } else {
            viewModel.startDownload(
                messageID: message.id,
                attachment: attachment,
                viewController: viewController
            )
        }
    }
}
