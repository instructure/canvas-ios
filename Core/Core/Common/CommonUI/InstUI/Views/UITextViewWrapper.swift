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

extension InstUI {

    /// This wrapper is a workaround to replace the `SwiftUI.TextEditor`.
    /// It clears the defult insets (allowing for proper alignment with other views),
    /// provides a `textViewSetup` closure for customization,
    /// updates the `height` binding if provided.
    /// Parent views and view hierarchy can affect its behaviour, especially when UITextView scrolling is disabled.
    /// Make sure to test for issues like text overflowing width, parent not scrolling, cursor jumping around, etc.
    public struct UITextViewWrapper: UIViewRepresentable {
        public typealias Context = UIViewRepresentableContext<UITextViewWrapper>

        @Binding private var text: String
        @Binding private var height: CGFloat
        private let textViewSetup: (UITextView) -> Void

        public init(
            text: Binding<String>,
            height: Binding<CGFloat> = .constant(0),
            textViewSetup: @escaping (UITextView) -> Void
        ) {
            self._text = text
            self._height = height
            self.textViewSetup = textViewSetup
        }

        public func makeCoordinator() -> Coordinator {
            .init(self)
        }

        public func makeUIView(context: Context) -> UITextView {
            let textView = UITextView()
            textViewSetup(textView)
            textView.delegate = context.coordinator

            // clear out the default insets
            textView.contentInset = .zero
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0

            // make textView follow font size changes dynamically
            textView.adjustsFontForContentSizeCategory = true

            textView.text = text
            updateHeight(textView)

            return textView
        }

        public func updateUIView(_ textView: UITextView, context: Context) {
            if textView.text != text {
                DispatchQueue.main.async {
                    textView.text = text
                }
            }

            // updating regardless of text change to react to font size changes
            updateHeight(textView)
        }

        private func updateHeight(_ textView: UITextView) {
            DispatchQueue.main.async {
                let sizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.width, height: 0))
                height = sizeThatFits.height
            }
        }

        public class Coordinator: NSObject, UITextViewDelegate {
            var parent: UITextViewWrapper

            init(_ parent: UITextViewWrapper) {
                self.parent = parent
            }

            public func textViewDidChange(_ textView: UITextView) {
                DispatchQueue.main.async { [weak self] in
                    self?.parent.text = textView.text
                    self?.parent.updateHeight(textView)
                }
            }
        }
    }
}
