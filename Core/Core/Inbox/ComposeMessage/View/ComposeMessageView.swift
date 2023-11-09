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

    @FocusState private var subjectTextFieldFocus: Bool
    @FocusState private var messageTextFieldFocus: Bool

    init(model: ComposeMessageViewModel) {
        self.model = model
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    headerView
                    Divider()
                    propertiesView
                    Divider()
                    bodyView
                        .frame(height: geometry.size.height)
                    Spacer()
                }
                .background(Color.backgroundLightest)
                .navigationBarItems(leading: cancelButton)
            }
            .onAppear {
                hideNavigationBarSeparator()
            }
        }
    }

    private func hideNavigationBarSeparator() {
        let navigationBar = controller.value.navigationController?.navigationBar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.shadowImage = UIImage()
        navigationBar?.standardAppearance = navigationBarAppearance
        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        navigationBar?.isTranslucent = true
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
        Button {
            model.sendButtonDidTap.accept(controller)
        } label: {
            sendButtonImage
        }
        .accessibility(label: Text("Send", bundle: .core))
        .disabled(!model.sendButtonActive)
        .frame(maxHeight: .infinity, alignment: .top)

    }

    private var sendButtonImage: some View {
        Image.circleArrowUpSolid
            .resizable()
            .frame(width: 35, height: 35)
            .foregroundStyle(model.sendButtonActive ? .accentColor : Color.backgroundMedium)
    }

    private var addRecipientButton: some View {
        Button {
            model.addRecipientButtonDidTap(viewController: controller)
        } label: {
            Image.addLine
                .foregroundColor(Color.textDarkest)
        }
        .accessibility(label: Text("Add recipient", bundle: .core))
    }

    private var headerView: some View {
        HStack(alignment: .center) {
            Text(model.subject.isEmpty ? model.title : model.subject)
                .multilineTextAlignment(.leading)
                .font(.semibold22)
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
            if model.selectedContext != nil {
                toView
                Divider()
            }
            subjectView
            Divider()
            individualView
        }
    }

    private var courseView: some View {
        Button {
            model.courseSelectButtonDidTap(viewController: controller)
        } label: {
            HStack {
                Text("Course", bundle: .core)
                    .font(.regular16, lineHeight: .condensed)
                    .foregroundColor(.textDark)
                if let context = model.selectedContext {
                    Text(context.name)
                        .font(.regular16, lineHeight: .condensed)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.textDarkest)
                }
                Spacer()
                DisclosureIndicator()
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .accessibility(label: Text("Select course", bundle: .core))
    }

    private var toView: some View {
        HStack {
            Text("To", bundle: .core)
                .font(.regular16, lineHeight: .condensed)
                .foregroundColor(.textDark)
                .onTapGesture {
                    model.addRecipientButtonDidTap(viewController: controller)
                }
                .accessibilitySortPriority(2)
            if !model.recipients.isEmpty {
                recipientsView
                    .accessibilitySortPriority(0)
            }
            Spacer()
            addRecipientButton
                .accessibilitySortPriority(1)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .accessibilityElement(children: .contain)
    }

    private var recipientsView: some View {
        WrappingHStack(models: model.recipients) { recipient in
            RecipientPillView(recipient: recipient, removeDidTap: { recipient in
                model.removeRecipientButtonDidTap(recipient: recipient)
            })
        }
    }

    private var subjectView: some View {
        HStack {
            Text("Subject", bundle: .core)
                .font(.regular16, lineHeight: .condensed)
                .foregroundColor(.textDark)
                .onTapGesture {
                    self.subjectTextFieldFocus = true
                }
                .accessibilityHidden(true)
            TextField("", text: $model.subject)
                .multilineTextAlignment(.leading)
                .font(.regular16, lineHeight: .condensed).foregroundColor(.textDarkest)
                .focused($subjectTextFieldFocus)
                .accessibility(label: Text("Subject", bundle: .core))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    private var individualView: some View {
        Toggle(isOn: $model.sendIndividual) {
            Text("Send individual message to each recipient", bundle: .core)
                .font(.regular16, lineHeight: .condensed)
                .foregroundColor(.textDarkest)
        }
        .tint(.accentColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var bodyView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Message", bundle: .core)
                    .font(.regular16, lineHeight: .condensed)
                    .foregroundColor(.textDark)
                    .onTapGesture {
                        self.messageTextFieldFocus = true
                    }
                    .accessibilityHidden(true)
                Spacer()
                Button {
                    model.attachmentbuttonDidTap(viewController: controller)
                } label: {
                    Image.paperclipLine
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.textDarkest)
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .accessibility(label: Text("Add attachment", bundle: .core))
            }
            .padding(.leading, 16)
            TextEditor(text: $model.bodyText)
                .iOS16HideListScrollContentBackground()
                .font(.regular16, lineHeight: .condensed)
                .focused($messageTextFieldFocus)
                .foregroundColor(.textDarkest)
                .padding(.horizontal, 12)
                .frame(minHeight: 60)
                .accessibility(label: Text("Message", bundle: .core))
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
