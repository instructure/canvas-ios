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
