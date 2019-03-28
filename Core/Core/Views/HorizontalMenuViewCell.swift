// Copyright © 2019 Instructure, Inc. All rights reserved.

import UIKit

class HorizontalMenuViewCell: UICollectionViewCell {

    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var selectionView: UIView!
    var selectionColor: UIColor? = UIColor.named(.borderDarkest)
    var font: UIFont? {
        didSet {
            textLabel.font = font
        }
    }

    var title: String? {
        didSet {
            textLabel.text = title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear

    }

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) { [weak self] in
                let selected = self?.isSelected ?? false
                self?.selectionView?.backgroundColor = selected ? self?.selectionColor : UIColor.clear
                self?.textLabel.textColor = selected ? self?.selectionColor : UIColor.named(.textDark)
            }
        }
    }
}
