//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import UIKit

public class RichContentToolbarView: UIView {
    @IBOutlet weak var undoButton: DynamicButton!
    @IBOutlet weak var redoButton: DynamicButton!
    @IBOutlet weak var boldButton: DynamicButton!
    @IBOutlet weak var italicButton: DynamicButton!
    @IBOutlet weak var textColorButton: DynamicButton!
    @IBOutlet weak var unorderedButton: DynamicButton!
    @IBOutlet weak var orderedButton: DynamicButton!
    @IBOutlet weak var linkButton: DynamicButton!
    @IBOutlet weak var cameraButton: DynamicButton!
    @IBOutlet weak var libraryButton: DynamicButton!
    @IBOutlet weak var toolsView: UIView!

    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var colorPickerHeight: NSLayoutConstraint!
    @IBOutlet weak var colorPickerStack: UIStackView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var whiteColorButton: UIButton!

    weak var textColorView: UIView?

    weak var controller: RichContentEditorViewController?

    var foreColor: UIColor = UIColor.named(.textDarkest)
    var linkHref: String?
    var linkText: String?
    var imageSrc: String?
    var imageAlt: String?

    public override init(frame: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45)) {
        super.init(frame: frame)
        loadFromXib()
        awakeFromNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 45)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .named(.backgroundLightest)
        translatesAutoresizingMaskIntoConstraints = false
        undoButton.accessibilityLabel = NSLocalizedString("Undo", bundle: .core, comment: "")
        redoButton.accessibilityLabel = NSLocalizedString("Redo", bundle: .core, comment: "")
        boldButton.accessibilityLabel = NSLocalizedString("Bold", bundle: .core, comment: "")
        italicButton.accessibilityLabel = NSLocalizedString("Italic", bundle: .core, comment: "")
        textColorButton.accessibilityLabel = NSLocalizedString("Text Color", bundle: .core, comment: "")
        unorderedButton.accessibilityLabel = NSLocalizedString("Unordered List", bundle: .core, comment: "")
        orderedButton.accessibilityLabel = NSLocalizedString("Ordered List", bundle: .core, comment: "")
        linkButton.accessibilityLabel = NSLocalizedString("Link", bundle: .core, comment: "")
        cameraButton.accessibilityLabel = NSLocalizedString("Camera", bundle: .core, comment: "")
        libraryButton.accessibilityLabel = NSLocalizedString("Image", bundle: .core, comment: "")
        toolsView.backgroundColor = .named(.backgroundLightest)

        let colors = colorPickerStack.arrangedSubviews
        colors[0].accessibilityValue = NSLocalizedString("white", bundle: .core, comment: "")
        colors[1].accessibilityValue = NSLocalizedString("black", bundle: .core, comment: "")
        colors[2].accessibilityValue = NSLocalizedString("grey", bundle: .core, comment: "")
        colors[3].accessibilityValue = NSLocalizedString("red", bundle: .core, comment: "")
        colors[4].accessibilityValue = NSLocalizedString("orange", bundle: .core, comment: "")
        colors[5].accessibilityValue = NSLocalizedString("yellow", bundle: .core, comment: "")
        colors[6].accessibilityValue = NSLocalizedString("green", bundle: .core, comment: "")
        colors[7].accessibilityValue = NSLocalizedString("blue", bundle: .core, comment: "")
        colors[8].accessibilityValue = NSLocalizedString("purple", bundle: .core, comment: "")
        for color in colors {
            color.accessibilityLabel = NSLocalizedString("Set text color", bundle: .core, comment: "")
        }

        colorPickerHeight.constant = 0
        colorPickerView.backgroundColor = .named(.backgroundLightest)
        colorPickerView.alpha = 0
        colorPickerView.transform = CGAffineTransform(translationX: 0, y: 45)

        let whiteColorBorder = UIView(frame: CGRect(x: 7, y: 7, width: 30, height: 30))
        whiteColorBorder.layer.borderColor = UIColor.named(.borderMedium).cgColor
        whiteColorBorder.layer.borderWidth = 1
        whiteColorBorder.layer.cornerRadius = 15
        whiteColorBorder.isUserInteractionEnabled = false
        whiteColorButton.addSubview(whiteColorBorder)

        let textColorView = UIView(frame: CGRect(x: 15.5, y: 27, width: 19, height: 5))
        textColorView.layer.borderColor = UIColor.named(.textDarkest).cgColor
        textColorView.layer.borderWidth = 1
        textColorView.isUserInteractionEnabled = false
        textColorButton.addSubview(textColorView)
        self.textColorView = textColorView

        updateState(nil)
    }

    func updateState(_ state: [String: Any?]?) {
        foreColor = UIColor(hexString: state?["foreColor"] as? String) ?? UIColor.named(.textDarkest)
        let foreColorHex = foreColor.hexString
        linkHref = state?["linkHref"] as? String
        linkText = state?["linkText"] as? String
        imageSrc = state?["imageSrc"] as? String
        imageAlt = state?["imageAlt"] as? String
        let active = Brand.shared.linkColor
        let inactive = UIColor.named(.textDarkest)
        undoButton.isEnabled = (state?["undo"] as? Bool) == true
        redoButton.isEnabled = (state?["redo"] as? Bool) == true
        boldButton.isSelected = (state?["bold"] as? Bool) == true
        italicButton.isSelected = (state?["italic"] as? Bool) == true
        unorderedButton.isSelected = (state?["unorderedList"] as? Bool) == true
        orderedButton.isSelected = (state?["orderedList"] as? Bool) == true
        linkButton.isSelected = linkHref != nil
        linkButton.accessibilityValue = linkHref
        cameraButton.isHidden = !UIImagePickerController.isSourceTypeAvailable(.camera)
        libraryButton.isHidden = !UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        libraryButton.isSelected = imageSrc != nil
        libraryButton.accessibilityValue = imageSrc
        for button in buttonStack.arrangedSubviews {
            button.tintColor = (button as? UIButton)?.isSelected == true ? active : inactive
        }

        textColorView?.backgroundColor = foreColor
        if foreColorHex == UIColor.white.hexString {
            textColorView?.layer.borderColor = UIColor.named(.borderMedium).cgColor
        } else {
            textColorView?.layer.borderColor = foreColor.cgColor
        }
        textColorButton.accessibilityValue = foreColorHex
        for color in colorPickerStack.arrangedSubviews {
            if color.tintColor.hexString == foreColorHex {
                (color as? UIButton)?.isSelected = true
                textColorButton?.accessibilityValue = color.accessibilityValue
            } else {
                (color as? UIButton)?.isSelected = false
            }
        }
    }

    @IBAction func undoAction(_ sender: UIButton) { controller?.undo() }
    @IBAction func redoAction(_ sender: UIButton) { controller?.redo() }
    @IBAction func boldAction(_ sender: UIButton) { controller?.toggleBold() }
    @IBAction func italicAction(_ sender: UIButton) { controller?.toggleItalic() }
    @IBAction func unorderedListAction(_ sender: UIButton) { controller?.toggleUnordered() }
    @IBAction func orderedListAction(_ sender: UIButton) { controller?.toggleOrdered() }

    @IBAction func textColorAction(_ sender: UIButton) {
        controller?.setTextColor(sender.tintColor)
        hideColorPicker()
    }

    @IBAction func toggleColorPicker(sender: UIButton) {
        if colorPickerView?.alpha == 0 {
            showColorPicker()
        } else {
            hideColorPicker()
        }
    }

    func showColorPicker() {
        colorPickerHeight?.constant = 45
        layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.colorPickerView.alpha = 1
            self.colorPickerView.transform = .identity
            self.layoutIfNeeded()
        }, completion: { _ in
            UIAccessibility.post(notification: .layoutChanged, argument: self.whiteColorButton)
        })
    }

    func hideColorPicker() {
        UIAccessibility.post(notification: .layoutChanged, argument: self.textColorButton)
        UIView.animate(withDuration: 0.2, animations: {
            self.colorPickerView.alpha = 0
            self.colorPickerView.transform = CGAffineTransform(translationX: 0, y: 45)
            self.layoutIfNeeded()
        }, completion: { _ in
            self.colorPickerHeight.constant = 0
            self.layoutIfNeeded()
        })
    }

    @IBAction func linkAction(_ sender: UIButton? = nil) {
        controller?.editLink(href: linkHref, text: linkText)
    }

    @IBAction func cameraAction(_ sender: UIButton) {
        controller?.insertFrom(.camera)
    }

    @IBAction func libraryAction(_ sender: UIButton) {
        controller?.insertFrom(.photoLibrary)
    }
}
