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

import SwiftUI
import UIKit

typealias OnAction = (Action, Int, Int) -> Void
typealias GetActionsCallback = (UITextView, UITextRange) -> [UIAction]

private class ActionableUITextView: UITextView {

    let getActionsCallback: GetActionsCallback?
    let onAction: OnAction?

    init(
        frame: CGRect,
        textContainer: NSTextContainer?,
        getActionsCallback: @escaping GetActionsCallback,
        onAction: OnAction? = nil
    ) {
        self.getActionsCallback = getActionsCallback
        self.onAction = onAction
        super.init(frame: frame, textContainer: textContainer)
    }

    required init?(coder: NSCoder) {
        self.onAction = nil
        self.getActionsCallback = nil
        super.init(coder: coder)
    }

    override func editMenu(for textRange: UITextRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        var menuActions = suggestedActions

        self.getActionsCallback?(self, textRange).forEach { action in
            menuActions.insert(action, at: 0)
        }

        return UIMenu(title: "", children: menuActions)
    }

}

struct TextSelection {
    let range: NSRange
    let action: Action
}

public struct NoteableTextView: UIViewRepresentable {
    private let text: String
    private let typography: HorizonUI.Typography.Name
    private let viewModel: NoteableTextViewModel

    public init(
        _ text: String,
        key: String,
        typography: HorizonUI.Typography.Name = .p1
    ) {
        self.text = text
        self.viewModel = NoteableTextViewModel(key: key)
        self.typography = typography
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = ActionableUITextView(
            frame: .zero,
            textContainer: nil,
            getActionsCallback: viewModel.getActions
        )

        textView.isEditable = false
        textView.isSelectable = true
        textView.attributedText = NSAttributedString(string: text)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
//        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        textView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.textContainer.maximumNumberOfLines = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.sizeToFit()

        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        let attributedText = NSMutableAttributedString(string: text)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = typography.lineSpacing

        attributedText.addAttributes(
            [
                .font: HorizonUI.fonts.uiFont(font: typography.font),
                .kern: typography.letterSpacing,
                .paragraphStyle: paragraphStyle
            ],
            range: NSRange(location: 0, length: text.count)
        )

        viewModel.selections.forEach { selection in
            attributedText.addAttribute(
                .backgroundColor,
                value: UIColor(selection.action.color).withAlphaComponent(0.25),
                range: selection.range
            )
        }

        uiView.attributedText = attributedText
        uiView.sizeToFit()
    }
}

enum Action {
    case confusing
    case important
    case addNote

    var color: Color {
        switch self {
        case .confusing: return Color.red
        case .important: return Color.blue
        case .addNote: return Color.green
        }
    }

    var label: String {
        switch self {
        case .confusing: return "Confusing"
        case .important: return "Important"
        case .addNote: return "Add a Note"
        }
    }
}

@Observable
@MainActor
public class NoteableTextViewModel {
    let key: String

    var selections: [TextSelection] = []

    init(key: String) {
        self.key = key
    }

    func getActions(textView: UITextView, textRange: UITextRange) -> [UIAction] {
        let allActions = [
            Action.confusing,
            Action.important,
            Action.addNote,
        ]

        //if the selection overlaps another section, don't show the actions
        let start = textView.offset(from: textView.beginningOfDocument, to: textRange.start)
        let end = textView.offset(from: textView.beginningOfDocument, to: textRange.end)
        if isOverlapping(start: start, end: end) {
            return []
        }

        return allActions.map { action in
            UIAction(title: action.label) { uiAction in
                self.onSelection(textView: textView, textRange: textRange, action: action, uiAction: uiAction)
            }
        }
    }

    private func onSelection(
        textView: UITextView,
        textRange: UITextRange,
        action: Action,
        uiAction: UIAction
    ) {
        let start = textView.offset(from: textView.beginningOfDocument, to: textRange.start)
        let end = textView.offset(from: textView.beginningOfDocument, to: textRange.end)

        //don't allow overlap
        if isOverlapping(start: start, end: end) {
            return
        }

        //otherwise, add a new selection
        let range = NSRange(location: start, length: end - start)
        let textSelection = TextSelection(range: range, action: action)
        selections.append(textSelection)
    }

    private func isOverlapping(start: Int, end: Int) -> Bool {
        selections.contains { selection in
            let selectionStart = selection.range.location
            let selectionEnd = selection.range.location + selection.range.length
            return (start < selectionStart && end > selectionStart) || (start < selectionEnd && end > selectionEnd)
                || (start >= selectionStart && end <= selectionEnd)
        }
    }
}

#Preview {
    VStack {
        Text("This text is not selectable. This text is not selectable. This text is not selectable.")
        NoteableTextView(
            "This is some text. You may select some of this text. This is some text. You may select some of this text. This is some text. You may select some of this text.",
            key: "Test",
            typography: .h3
        )
        Text("Again this is not selectable. Where is it? Again this is not selectable. Where is it? Again this is not selectable. Where is it? Again this is not selectable. Where is it? Again this is not selectable. Where is it? Again this is not selectable. Where is it? Again this is not selectable. Where is it? Again this is not selectable. Where is it? Again this is not selectable. Where is it?")
    }
}
