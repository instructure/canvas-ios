//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import WhizzyWig
import SoPretty

// TODO: share this dup'ed stuff with whizzy wig cell
class HTMLAnswerCell: UITableViewCell {
    
    class var ReuseID: String {
        return "HTMLAnswerCellReuseID"
    }
    
    class var Nib: UINib {
        return UINib(nibName: "HTMLAnswerCell", bundle: NSBundle(forClass: self.classForCoder()))
    }
    
    var indexPath = NSIndexPath(forRow: 0, inSection: 0)
    var cellSizeUpdated: NSIndexPath->() = {_ in }
    
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
    
    private func setup() {
        selectionStyle = .None
        
        whizzyWigView.contentBackgroundColor = UIColor.prettyLightGray()
        whizzyWigView.contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        whizzyWigView.contentFinishedLoading = { [weak self] in
            if let me = self {
                me.contentSizeDidChange()
            }
        }
        
        selectionStatusImageView.tintColor = Brand.current().secondaryTintColor
    }
    
    private func contentSizeDidChange() {
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
        indexPath = NSIndexPath(forRow: 0, inSection: 0)
        cellSizeUpdated = {_ in }
        
        selectionStatusImageView.hidden = true
    }
}

extension HTMLAnswerCell: SelectableAnswerCell {
    func configureForState(selected selected: Bool) {
        selectionStatusImageView.hidden = !selected
    }
}