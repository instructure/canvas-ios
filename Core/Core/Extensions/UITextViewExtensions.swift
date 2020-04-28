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

import Foundation

extension UITextView {

    private class PlaceholderLabel: UILabel { }

    private var placeholderLabel: PlaceholderLabel {
        if let label = subviews.compactMap({ $0 as? PlaceholderLabel }).first {
            return label
        } else {
            let label = PlaceholderLabel(frame: .zero)
            label.font = font
            addSubview(label)
            resizePlaceholder()
            observeProperties()
            return label
        }
    }

    private func observeProperties() {
        let observingKeys = ["frame", "bounds"]
        for key in observingKeys {
            addObserver(self, forKeyPath: key, options: [.new], context: nil)
        }
    }

    //  swiftlint:disable:next block_based_kvo
    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        resizePlaceholder()
    }

    private func resizePlaceholder() {
        let lineFragmentPadding = textContainer.lineFragmentPadding
        let x: CGFloat = lineFragmentPadding + textContainerInset.left

        print("lineFragmentPadding: \(lineFragmentPadding)")
        print("textContainerInset.left: \(textContainerInset.left)")
        print("x: \(x)")

        let y: CGFloat = textContainerInset.top
        let width: CGFloat = bounds.width - x - lineFragmentPadding - textContainerInset.right
        let height: CGFloat = placeholderLabel.sizeThatFits(CGSize(width: width, height: 0)).height
        placeholderLabel.frame = CGRect(x: x, y: y, width: width, height: height)
    }

    @IBInspectable
    public var placeholder: String {
        get {
            return subviews.compactMap({ $0 as? PlaceholderLabel }).first?.text ?? ""
        }
        set {
            let placeholderLabel = self.placeholderLabel
            placeholderLabel.text = newValue
            placeholderLabel.numberOfLines = 0
            resizePlaceholder()
            textStorage.delegate = self
        }
    }

    @IBInspectable
    public var placeholderColor: UIColor? {
        get {
            return placeholderLabel.textColor
        }
        set {
            placeholderLabel.textColor = newValue
        }
    }
}

extension UITextView: NSTextStorageDelegate {
    public func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorage.EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        if editedMask.contains(.editedCharacters) {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
}
