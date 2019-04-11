//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import UIKit

public class RichContentToolbarView: UIView {
    @IBOutlet weak var undoButton: DynamicButton?
    @IBOutlet weak var redoButton: DynamicButton?
    @IBOutlet weak var boldButton: DynamicButton?
    @IBOutlet weak var italicButton: DynamicButton?
    @IBOutlet weak var textColorButton: DynamicButton?
    @IBOutlet weak var unorderedButton: DynamicButton?
    @IBOutlet weak var orderedButton: DynamicButton?
    @IBOutlet weak var linkButton: DynamicButton?
    @IBOutlet weak var imageButton: DynamicButton?

    @IBOutlet weak var colorPickerHeight: NSLayoutConstraint?
    @IBOutlet weak var colorPickerStack: UIStackView?
    @IBOutlet weak var colorPickerView: UIView?
    @IBOutlet weak var whiteColorButton: UIView?

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
        translatesAutoresizingMaskIntoConstraints = false
        undoButton?.accessibilityLabel = NSLocalizedString("Undo", bundle: .core, comment: "")
        redoButton?.accessibilityLabel = NSLocalizedString("Redo", bundle: .core, comment: "")
        boldButton?.accessibilityLabel = NSLocalizedString("Bold", bundle: .core, comment: "")
        italicButton?.accessibilityLabel = NSLocalizedString("Italic", bundle: .core, comment: "")
        textColorButton?.accessibilityLabel = NSLocalizedString("Text Color", bundle: .core, comment: "")
        unorderedButton?.accessibilityLabel = NSLocalizedString("Unordered List", bundle: .core, comment: "")
        orderedButton?.accessibilityLabel = NSLocalizedString("Ordered List", bundle: .core, comment: "")
        linkButton?.accessibilityLabel = NSLocalizedString("Link", bundle: .core, comment: "")
        imageButton?.accessibilityLabel = NSLocalizedString("Image", bundle: .core, comment: "")

        let colors = colorPickerStack?.arrangedSubviews
        colors?[0].accessibilityLabel = NSLocalizedString("Set text color white", bundle: .core, comment: "")
        colors?[1].accessibilityLabel = NSLocalizedString("Set text color black", bundle: .core, comment: "")
        colors?[2].accessibilityLabel = NSLocalizedString("Set text color grey", bundle: .core, comment: "")
        colors?[3].accessibilityLabel = NSLocalizedString("Set text color red", bundle: .core, comment: "")
        colors?[4].accessibilityLabel = NSLocalizedString("Set text color orange", bundle: .core, comment: "")
        colors?[5].accessibilityLabel = NSLocalizedString("Set text color yellow", bundle: .core, comment: "")
        colors?[6].accessibilityLabel = NSLocalizedString("Set text color green", bundle: .core, comment: "")
        colors?[7].accessibilityLabel = NSLocalizedString("Set text color blue", bundle: .core, comment: "")
        colors?[8].accessibilityLabel = NSLocalizedString("Set text color purple", bundle: .core, comment: "")

        // TODO: unhide this when implemented
        imageButton?.isHidden = true

        colorPickerHeight?.constant = 0
        colorPickerView?.alpha = 0
        colorPickerView?.transform = CGAffineTransform(translationX: 0, y: 45)

        let whiteColorBorder = UIView(frame: CGRect(x: 7, y: 7, width: 30, height: 30))
        whiteColorBorder.layer.borderColor = UIColor.named(.borderMedium).cgColor
        whiteColorBorder.layer.borderWidth = 1
        whiteColorBorder.layer.cornerRadius = 15
        whiteColorBorder.isUserInteractionEnabled = false
        whiteColorButton?.addSubview(whiteColorBorder)

        let textColorView = UIView(frame: CGRect(x: 16.5, y: 27, width: 17, height: 4.5))
        textColorView.layer.borderColor = UIColor.named(.textDarkest).cgColor
        textColorView.layer.borderWidth = 1
        textColorView.isUserInteractionEnabled = false
        textColorButton?.addSubview(textColorView)
        self.textColorView = textColorView

        updateState(nil)
    }

    func updateState(_ state: [String: Any?]?) {
        foreColor = UIColor(hexString: state?["foreColor"] as? String) ?? UIColor.named(.textDarkest)
        linkHref = state?["linkHref"] as? String
        linkText = state?["linkText"] as? String
        imageSrc = state?["imageSrc"] as? String
        imageAlt = state?["imageAlt"] as? String
        let active = Brand.shared.linkColor
        let inactive = UIColor.named(.textDarkest)
        boldButton?.tintColor = (state?["bold"] as? Bool) == true ? active : inactive
        italicButton?.tintColor = (state?["italic"] as? Bool) == true ? active : inactive
        unorderedButton?.tintColor = (state?["unorderedList"] as? Bool) == true ? active : inactive
        orderedButton?.tintColor = (state?["orderedList"] as? Bool) == true ? active : inactive
        linkButton?.tintColor = linkHref != nil ? active : inactive
        imageButton?.tintColor = imageSrc != nil ? active : inactive

        textColorView?.backgroundColor = foreColor
        if foreColor.hexString == UIColor.white.hexString {
            textColorView?.layer.borderColor = UIColor.named(.borderMedium).cgColor
        } else {
            textColorView?.layer.borderColor = foreColor.cgColor
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
        controller?.backupRange()
        colorPickerHeight?.constant = 45
        layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.colorPickerView?.alpha = 1
            self.colorPickerView?.transform = .identity
            self.layoutIfNeeded()
        }
    }

    func hideColorPicker() {
        UIView.animate(withDuration: 0.2, animations: {
            self.colorPickerView?.alpha = 0
            self.colorPickerView?.transform = CGAffineTransform(translationX: 0, y: 45)
            self.layoutIfNeeded()
        }, completion: { _ in
            self.colorPickerHeight?.constant = 0
            self.layoutIfNeeded()
        })
    }

    @IBAction func linkAction(_ sender: UIButton) {
        controller?.backupRange()
        let alert = UIAlertController(title: NSLocalizedString("Link to Website URL", bundle: .core, comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField { (field: UITextField) in
            field.placeholder = NSLocalizedString("Text", bundle: .core, comment: "")
            field.text = self.linkText
        }
        alert.addTextField { (field: UITextField) in
            field.placeholder = NSLocalizedString("URL", bundle: .core, comment: "")
            field.text = self.linkHref
            field.keyboardType = .URL
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", bundle: .core, comment: ""), style: .default) { _ in
            let text = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            var href = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !href.isEmpty, URLComponents.parse(href).scheme == nil {
                href = "http://\(href)"
            }
            self.controller?.updateLink(href: href, text: text)
        })
        controller?.present(alert, animated: true)

    }

    @IBAction func imageAction(_ sender: UIButton) {
        // TODO
        // controller?.updateImage(src: src, alt: alt)
    }
}
