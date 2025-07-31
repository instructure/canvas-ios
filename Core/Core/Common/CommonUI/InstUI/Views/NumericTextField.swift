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

import Foundation
import SwiftUI

extension InstUI {
    public struct NumericTextField: UIViewRepresentable {
        public typealias Context = UIViewRepresentableContext<NumericTextField>

        public struct Style {
            let textColor: UIColor
            let textFont: UIFont.Name
            let placeholderFont: UIFont.Name
            let textAlignment: NSTextAlignment

            public init(
                textColor: UIColor,
                textFont: UIFont.Name,
                placeholderFont: UIFont.Name? = nil,
                textAlignment: NSTextAlignment = .right
            ) {
                self.textColor = textColor
                self.textFont = textFont
                self.placeholderFont = placeholderFont ?? textFont
                self.textAlignment = textAlignment
            }
        }

        @Binding private var text: String
        private let placeholder: String
        private let hasDecimal: Bool
        private let style: Style

        public init(
            text: Binding<String>,
            placeholder: String,
            hasDecimal: Bool = true,
            style: Style
        ) {
            self._text = text
            self.placeholder = placeholder
            self.hasDecimal = hasDecimal
            self.style = style
        }

        public func makeCoordinator() -> Coordinator {
            .init(self)
        }

        public func makeUIView(context: Context) -> UITextField {
            let textField = UITextField()
            textField.delegate = context.coordinator

            // Style
            textField.textColor = style.textColor
            textField.font = .scaledNamedFont(style.textFont)
            let placeholderAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.textPlaceholder,
                .font: UIFont.scaledNamedFont(style.placeholderFont)
            ]
            textField.textAlignment = style.textAlignment

            // Keyboard
            textField.keyboardType = hasDecimal ? .decimalPad : .numberPad
            textField.returnKeyType = .done

            // Make textView follow font size changes dynamically
            textField.adjustsFontForContentSizeCategory = true

            // Done button
            let doneButton = UIBarButtonItemWithCompletion(
                title: String(localized: "Done", bundle: .core),
                style: .done
            ) {
                textField.resignFirstResponder()
            }

            // Toolbar
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                doneButton
            ]
            textField.inputAccessoryView = toolbar

            // Texts
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: placeholderAttributes
            )
            textField.text = text

            return textField
        }

        public func updateUIView(_ textField: UITextField, context: Context) {
            if textField.text != text {
                DispatchQueue.main.async {
                    textField.text = text
                }
            }
        }

        public class Coordinator: NSObject, UITextFieldDelegate {
            private let parent: NumericTextField

            init(_ parent: NumericTextField) {
                self.parent = parent
            }

            public func textFieldDidChangeSelection(_ textField: UITextField) {
                parent.text = textField.text ?? ""
            }

            public func textFieldDidBeginEditing(_ textField: UITextField) {
                // when focused: select text
                if parent.text.isNotEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        textField.selectAll(nil)
                    }
                }
            }

            public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
            }
        }
    }
}
