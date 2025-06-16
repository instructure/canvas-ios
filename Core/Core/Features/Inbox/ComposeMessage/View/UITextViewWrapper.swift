//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public struct UITextViewWrapper: UIViewRepresentable {
    public typealias Context = UIViewRepresentableContext<UITextViewWrapper>

    @Binding var text: String
    let textViewBuilder: () -> UITextView

    public init(
        text: Binding<String>,
        textViewBuilder: @escaping () -> UITextView
    ) {
        self._text = text
        self.textViewBuilder = textViewBuilder
    }

    public func makeCoordinator() -> Coordinator {
        .init(self)
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = textViewBuilder()
        textView.delegate = context.coordinator
        textView.adjustsFontForContentSizeCategory = true
        return textView
    }

    public func updateUIView(_ textView: UITextView, context: Context) {
        if text != textView.text {
            textView.text = text
        }
        textView.textColor = .textDarkest
    }


    public class Coordinator: NSObject, UITextViewDelegate {

        var parent: UITextViewWrapper

        init(_ textField: UITextViewWrapper) {
            self.parent = textField
        }

        public func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
