//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

struct TextArea: View {
    @Binding private var text: String
    private let placeholder: String?
    private let errorMessage: String?
    private let proxy: GeometryProxy
    private let onSubmit: (() -> Void)?

    init(
        text: Binding<String>,
        placeholder: String? = nil,
        errorMessage: String? = nil,
        proxy: GeometryProxy,
        onSubmit: (() -> Void)? = nil
    ) {
        _text = text
        self.placeholder = placeholder
        self.errorMessage = errorMessage
        self.proxy = proxy
        self.onSubmit = onSubmit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            textField
                .background(Color.huiColors.surface.cardPrimary)
                .huiBorder(
                    level: .level1,
                    color: errorMessage != nil
                    ? .huiColors.surface.error
                    : .huiColors.lineAndBorders.containerStroke,
                    radius: HorizonUI.CornerRadius.level1_5.attributes.radius
                )
                .huiCornerRadius(level: .level1_5)
                .huiTypography(.p1)

            if let errorMessage {
                HorizonUI.StatusChip(
                    title: errorMessage,
                    style: .red,
                    icon: Image.huiIcons.error,
                    isFilled: false,
                )
                .padding(.top, .huiSpaces.space8)
            }
        }
    }

    private var textField: some View {
        InstUI.UITextViewWrapper(text: $text) { textView in
            configureLayout(for: textView)
            configureToolbar(for: textView)
        }
        .foregroundStyle(text.isEmpty ? Color.huiColors.text.placeholder : Color.huiColors.text.body)
        .frame(minHeight: 120, alignment: .top)
        .padding(.vertical, .huiSpaces.space8)
        .padding(.horizontal, .huiSpaces.space12)
        .overlay(placeholderView, alignment: .topLeading)
    }

    // MARK: - Configuration Helpers

    private func configureLayout(for textView: UITextView) {
        textView.isScrollEnabled = false
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.font = HorizonUI.fonts.uiFont(font: HorizonUI.Typography.Name.p1.font)

        if textView.constraints.isEmpty {
            textView.translatesAutoresizingMaskIntoConstraints = false
            let width = proxy.frame(in: .global).width - (4 * .huiSpaces.space32)
            textView.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }

    private func configureToolbar(for textView: UITextView) {
        // Only proceed if we have a submit action and VoiceOver is running
        guard let onSubmit, UIAccessibility.isVoiceOverRunning else { return }

        // If the toolbar is already set, don't recreate it
        if textView.inputAccessoryView != nil { return }

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let submitAction = UIAction { [weak textView] _ in
            onSubmit()
            textView?.resignFirstResponder()
        }

        let submitButton = UIBarButtonItem(
            title: String(localized: "Submit"),
            primaryAction: submitAction
        )
        submitButton.style = .done
        submitButton.accessibilityLabel = String(localized: "Submit")
        submitButton.accessibilityHint = String(localized: "Double tap to submit")

        toolbar.items = [flexSpace, submitButton]
        textView.inputAccessoryView = toolbar
    }

    @ViewBuilder
    private var placeholderView: some View {
        if let placeholder, text.isEmpty {
            Text(placeholder)
                .foregroundStyle(Color.huiColors.text.placeholder)
                .huiTypography(.p1)
                .allowsHitTesting(false)
                .accessibility(hidden: true)
                .padding(.vertical, .huiSpaces.space8)
                .padding(.horizontal, .huiSpaces.space12)
        }
    }
}

private class SubmitButtonHandler: NSObject {
    let onSubmit: () -> Void

    init(onSubmit: @escaping () -> Void) {
        self.onSubmit = onSubmit
    }

    @objc func handleSubmit() {
        onSubmit()
    }
}

private struct AssociatedKeys {
    static var submitHandler: UInt8 = 0
}
