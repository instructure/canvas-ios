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

import SwiftUI

public struct InboxSettingsView: View {
    private let defaultPadding: CGFloat = 10
    @ObservedObject private var viewModel: InboxSettingsViewModel
    @Environment(\.viewController) private var controller
    @FocusState private var focusedInput: FocusedInput?
    private enum FocusedInput {
        case signature
    }

    public init(viewModel: InboxSettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state
        ) { geometry in
            contentView(geometry: geometry)
        }
        .navigationBarTitleView(String(localized: "Inbox Signature", bundle: .core))
        .navigationBarItems(trailing: doneButton)
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
    }

    private var doneButton: some View {
        Button {
            viewModel.didTapSave.accept(controller)
        } label: {
            Text("Save", bundle: .core)
                .foregroundColor(.accentColor)
        }
        .disabled(!viewModel.enableSaveButton)
    }

    func contentView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: defaultPadding)
            Text("Signature will be added to the end of all messaging.", bundle: .core)
                .font(.regular14, lineHeight: .condensed)
                .foregroundColor(.textDark)
                .padding(defaultPadding)

            separator

            InstUI.Toggle(isOn: $viewModel.useSignature) {
                Text("Signature", bundle: .core)
                    .font(.semibold16, lineHeight: .condensed)
                    .foregroundColor(.textDarkest)
            }
            .tint(.accentColor)
            .padding(defaultPadding)

            separator

            VStack(alignment: .leading, spacing: 0) {
                Text("Signature text", bundle: .core)
                    .font(.semibold16, lineHeight: .condensed)
                    .foregroundColor(.textDarkest)
                    .onTapGesture {
                        self.focusedInput = .signature
                    }
                    .accessibilityHidden(true)
                    .padding(.vertical, defaultPadding)

                UITextViewWrapper(text: $viewModel.signature) {
                    let tv = UITextView()
                    tv.placeholder = String(localized: "Write your signature here", bundle: .core)
                    tv.placeholderColor = .textPlaceholder
                    tv.isScrollEnabled = false
                    tv.textContainer.widthTracksTextView = true
                    tv.textContainer.lineBreakMode = .byWordWrapping
                    tv.font = UIFont.scaledNamedFont(.regular16)
                    tv.translatesAutoresizingMaskIntoConstraints = false
                    tv.widthAnchor.constraint(equalToConstant: geometry.frame(in: .global).width - (2 * defaultPadding)).isActive = true
                    tv.backgroundColor = .backgroundLightest
                    return tv
                }
                .font(.regular16, lineHeight: .condensed)
                .textInputAutocapitalization(.sentences)
                .focused($focusedInput, equals: .signature)
                .foregroundColor(.textDarkest)
                .disabled(!viewModel.useSignature)
                .opacity(!viewModel.useSignature ? 0.6 : 1)
                .frame(minHeight: 60)
                .accessibilityLabel(Text("Signature Input", bundle: .core))
                .accessibilityHint(Text("Write your Signature text here", bundle: .core))
                .accessibilityIdentifier("InboxSettings.signature")
            }
            .padding(defaultPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
