//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

// Meant to be a fill-in for the SwiftUI.TextEditor available in iOS 14. This component implements a custom height sizing behavior, make sure when you update to iOS 14 to keep the UX consistent.
@available(iOS, deprecated: 14)
public struct TextEditor: View {
    @Binding var text: String
    @State var height: CGFloat?
    let maxHeight: CGFloat

    private var textFont = UIFont.preferredFont(forTextStyle: .body)
    public func font(_ name: UIFont.Name) -> TextEditor {
        var copy = self
        copy.textFont = .scaledNamedFont(name)
        return copy
    }

    private var textColor = UIColor.black
    public func foregroundColor(_ color: UIColor) -> TextEditor {
        var copy = self
        copy.textColor = color
        return copy
    }

    /**
     - parameters:
        - maxHeight: This property limits how large the text box can grow. After reaching this height scrolling is turned on.
     */
    public init(text: Binding<String>, maxHeight: CGFloat) {
        _text = text
        self.maxHeight = maxHeight
    }

    public var body: some View {
        let textViewHeight: CGFloat? = {
            if let height = height {
                return min(height, maxHeight)
            }
            return nil
        }()
        TextView(height: $height, text: $text, color: textColor, font: textFont, maxHeight: maxHeight)
            .frame(height: textViewHeight)
            .clipped()
    }

    struct TextView: UIViewRepresentable {
        @Binding var height: CGFloat?
        @Binding var text: String
        let color: UIColor
        let font: UIFont
        let maxHeight: CGFloat

        func makeUIView(context: Self.Context) -> UITextView {
            let uiView = UITextView()
            uiView.adjustsFontForContentSizeCategory = true
            uiView.backgroundColor = .clear
            uiView.delegate = context.coordinator
            uiView.isEditable = true
            uiView.isScrollEnabled = false
            uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            uiView.textContainer.lineFragmentPadding = 0
            uiView.textContainerInset = .zero
            return uiView
        }

        func updateUIView(_ uiView: UITextView, context: Self.Context) {
            if uiView.text != text {
                uiView.text = text
            }
            uiView.delegate = context.coordinator
            uiView.font = font
            uiView.textColor = color
            switch (context.environment.multilineTextAlignment, context.environment.layoutDirection) {
            case (.leading, .rightToLeft):
                uiView.textAlignment = .right
            case (.trailing, .rightToLeft):
                uiView.textAlignment = .left
            case (.leading, _):
                uiView.textAlignment = .left
            case (.trailing, _):
                uiView.textAlignment = .right
            case (.center, _):
                uiView.textAlignment = .center
            }
            DispatchQueue.main.async { updateHeight(uiView) }
        }

        class Coordinator: NSObject, UITextViewDelegate {
            let view: TextView
            var lastText: String = ""

            init(_ view: TextView) {
                self.view = view
            }

            func textViewDidChange(_ textView: UITextView) {
                guard view.text != textView.text else { return }
                view.text = textView.text
                view.updateHeight(textView)
            }
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }

        func updateHeight(_ uiView: UITextView) {
            let size = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: .greatestFiniteMagnitude))

            if size.height != height {
                height = size.height
                uiView.isScrollEnabled = (size.height + 10 >= maxHeight)
            }
        }
    }
}
