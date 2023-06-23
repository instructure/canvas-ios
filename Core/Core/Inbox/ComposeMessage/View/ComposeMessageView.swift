//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct ComposeMessageView: View {
    @ObservedObject private var model: ComposeMessageViewModel
    @Environment(\.viewController) private var controller

    init(model: ComposeMessageViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 0) {
            Divider()
            courseView
            Divider()
            toView
            Divider()
            subjectView
            Divider()
            individualView
            Divider()
            bodyView
        }
        .background(Color.backgroundLightest)
        .navigationBarTitle(model.title, displayMode: .inline)
        .navBarItems(leading: cancelButton, trailing: sendButton)
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
    }

    private var cancelButton: some View {
        Button {
            model.cancelButtonDidTap.accept(controller)
        } label: {
            Text("Cancel", bundle: .core)
                .font(.regular16)
                .foregroundColor(.textDarkest)
        }
    }

    private var sendButton: some View {
        Button(action: {
            model.sendButtonDidTap.accept(controller)
        }, label: {
            Image.send
                .frame(width: 20, height: 20)
        })
        .accessibility(label: Text("Send", bundle: .core))
    }

    private var addRecipientButton: some View {
        Button(action: {
            model.addRecipientButtonDidTap.accept(controller)
        }, label: {
            Image.addLine
                .foregroundColor(Color.textDarkest)
        })
        .accessibility(label: Text("Add recipient", bundle: .core))
    }

    private var courseView: some View {
        Button(action: {
            model.courseSelectButtonDidTap(viewController: controller)
        }, label: {
            HStack {
                Text("Select Course")
                    .font(.medium16)
                    .foregroundColor(.textDark)
                Spacer()
                DisclosureIndicator().padding(.trailing, 16)
            }
        })
        .accessibility(label: Text("Add recipient", bundle: .core))
    }

    private var toView: some View {
        HStack {
            Text("To")
                .font(.medium16)
                .foregroundColor(.textDark)
            Spacer()
            addRecipientButton
        }
    }

    private var subjectView: some View {
        TextFieldRow(
            label: Text("Subject", bundle: .core),
            placeholder: "",
            text: $model.subject
        )
    }

    private var individualView: some View {
        Toggle(isOn: $model.sendIndividual, label: {
            Text("Send individual message to each recipient")
                .font(.medium16)
                .foregroundColor(.textDark)
        })
    }

    private var bodyView: some View {
        CustomTextField(placeholder: Text("Compose message", bundle: .core),
                        text: $model.bodyText,
                        identifier: "composeMessage.body",
                        accessibilityLabel: Text("Message Body", bundle: .core))
        .frame(maxHeight: .infinity)
    }
}
