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
            headerView
            Divider()
            propertiesView
            Divider()
            bodyView
            Spacer()
        }
        .background(Color.backgroundLightest)
        .navigationBarItems(leading: cancelButton)
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
            sendButtonImage
        })
        .accessibility(label: Text("Send", bundle: .core))
        .disabled(!model.sendButtonActive)
    }
    
    private var sendButtonImage: some View {
        Image.send.grayscale(model.sendButtonActive ? 0 : 0.8).opacity(model.sendButtonActive ? 1 : 0.5).frame(width: 20, height: 20)
    }

    private var addRecipientButton: some View {
        Button(action: {
            model.addRecipientButtonDidTap(viewController: controller)
        }, label: {
            Image.addLine
                .foregroundColor(Color.textDarkest)
        })
        .accessibility(label: Text("Add recipient", bundle: .core))
    }

    private var headerView: some View {
        HStack {
            Text(model.subject.isEmpty ? model.title : model.subject)
                .multilineTextAlignment(.leading)
                .font(.bold22)
                .foregroundColor(.textDarkest)
            Spacer()
            sendButton
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .frame(minHeight: 52)
    }

    private var propertiesView: some View {
        VStack(spacing: 0) {
            courseView
            Divider()
            if (model.selectedCourse != nil) {
                toView
                Divider()
            }
            subjectView
            Divider()
            individualView
        }
    }

    private var courseView: some View {
        Button(action: {
            model.courseSelectButtonDidTap(viewController: controller)
        }, label: {
            HStack {
                Text("Course")
                    .font(.regular16)
                    .foregroundColor(.textDark)
                if let course = model.selectedCourse {
                    Text(course.name)
                        .font(.regular16)
                        .foregroundColor(.textDark)
                }
                Spacer()
                DisclosureIndicator()
            }
        })
        .padding(.horizontal, 16).padding(.vertical, 12)
        .accessibility(label: Text("Add recipient", bundle: .core))
    }

    private var toView: some View {
        HStack {
            Text("To")
                .font(.regular16)
                .foregroundColor(.textDark)
            if !model.recipients.isEmpty {
                recipientsView
            }
            Spacer()
            addRecipientButton
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    private var recipientsView: some View {
        WrappingHStack(models: model.recipients) { recipient in
            RecipientPillView(recipient: recipient, removeDidTap: { recipient in model.removeRecipientButtonDidTap(recipient: recipient) })
        }
    }

    private var subjectView: some View {
        HStack {
            Text("Subject", bundle: .core)
                .font(.regular16)
                .foregroundColor(.textDark)
            TextField("", text: $model.subject)
                .multilineTextAlignment(.leading)
                .font(.regular16).foregroundColor(.textDarkest)
                .accessibility(label: Text("Subject", bundle: .core))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    private var individualView: some View {
        Toggle(isOn: $model.sendIndividual, label: {
            Text("Send individual message to each recipient")
                .font(.regular16)
                .foregroundColor(.textDark)
        })
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    private var bodyView: some View {
        VStack {
            HStack {
                Text("Message")
                    .font(.regular16)
                    .foregroundColor(.textDark)
                Spacer()
                Button(action: {
                    model.attachmentbuttonDidTap(viewController: controller)
                }, label: {
                    Image.paperclipLine.frame(width: 20, height: 20)
                })
                .accessibility(label: Text("Attachment", bundle: .core))
            }
            .padding(.top, 16).padding(.horizontal, 12)
            DynamicHeightTextEditor(text: $model.bodyText, placeholder: NSLocalizedString("", comment: ""))
                .font(.regular16)
                .foregroundColor(.textDarkest)
                .padding(.horizontal, 12).padding(.bottom, 12)
        }
    }
}

#if DEBUG

struct ComposeMessageView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()

    static var previews: some View {
        ComposeMessageAssembly.makePreview(env: env)
    }
}

#endif
