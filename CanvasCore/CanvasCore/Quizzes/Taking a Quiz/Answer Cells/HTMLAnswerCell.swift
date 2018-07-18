//
// Copyright (C) 2016-present Instructure, Inc.
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



// TODO: share this dup'ed stuff with whizzy wig cell
class HTMLAnswerCell: UITableViewCell {
    
    class var ReuseID: String {
        return "HTMLAnswerCellReuseID"
    }
    
    class var Nib: UINib {
        return UINib(nibName: "HTMLAnswerCell", bundle: Bundle(for: self.classForCoder()))
    }
    
    var indexPath = IndexPath(row: 0, section: 0)
    var cellSizeUpdated: (IndexPath)->() = {_ in }
    
    var minHeight: CGFloat = 43.0
    var maxHeight: CGFloat = 2048.0
    
    @IBOutlet var whizzyWigView: WhizzyWigView!
    @IBOutlet var whizzyWigViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var selectionStatusImageView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
    
    
    var expectedHeight: CGFloat {
        get {
            return whizzyWigViewHeightConstraint.constant + (15 * 2) + (9 * 2)
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
