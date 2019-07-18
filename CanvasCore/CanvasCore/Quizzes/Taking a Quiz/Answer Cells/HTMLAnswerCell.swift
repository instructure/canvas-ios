//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit



// TODO: share this dup'ed stuff with whizzy wig cell
class HTMLAnswerCell: UITableViewCell {
    
    @objc class var ReuseID: String {
        return "HTMLAnswerCellReuseID"
    }
    
    @objc class var Nib: UINib {
        return UINib(nibName: "HTMLAnswerCell", bundle: Bundle(for: self.classForCoder()))
    }
    
    @objc var indexPath = IndexPath(row: 0, section: 0)
    @objc var cellSizeUpdated: (IndexPath)->() = {_ in }
    
    @objc var minHeight: CGFloat = 43.0
    @objc var maxHeight: CGFloat = 2048.0
    
    @IBOutlet var whizzyWigView: WhizzyWigView!
    @IBOutlet var whizzyWigViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var selectionStatusImageView: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    fileprivate func setup() {
        selectionStyle = .none
        
        whizzyWigView.contentBackgroundColor = UIColor.prettyLightGray()
        whizzyWigView.contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        whizzyWigView.contentFinishedLoading = { [weak self] in
            if let me = self {
                me.contentSizeDidChange()
            }
        }
        
        selectionStatusImageView.tintColor = Brand.current.secondaryTintColor
    }
    
    fileprivate func contentSizeDidChange() {
        let contentHeight = whizzyWigView.contentHeight
        whizzyWigViewHeightConstraint.constant = min(maxHeight, max(minHeight, contentHeight))
        cellSizeUpdated(indexPath)
    }
    
    
    @objc var expectedHeight: CGFloat {
        get {
            let padding: CGFloat = 48
            return whizzyWigViewHeightConstraint.constant + padding
        }
        set {
            whizzyWigViewHeightConstraint.constant = min(max(minHeight, newValue), maxHeight)
            contentView.setNeedsLayout()
        }
    }
    
    override func prepareForReuse() {
        indexPath = IndexPath(row: 0, section: 0)
        cellSizeUpdated = {_ in }
        
        selectionStatusImageView.isHidden = true
    }
}

extension HTMLAnswerCell: SelectableAnswerCell {
    func configureForState(selected: Bool) {
        selectionStatusImageView.isHidden = !selected
    }
}
