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

open class WhizzyWigTableViewCell: UITableViewCell {
    
    open var indexPath = IndexPath(row: 0, section: 0)
    open var cellSizeUpdated: (IndexPath)->() = {_ in }
    open var readMore: ((WhizzyWigViewController)->())? {
        didSet {
            readMoreButton.isHidden = readMore == nil || whizzyWigView.contentHeight <= maxHeight
        }
    }
    
    var minHeight: CGFloat = 0.0
    var maxHeight: CGFloat = 6144.0
    
    open let whizzyWigView = WhizzyWigView(frame: CGRect(x: 0, y: 0, width: 320, height: 43))
    
    let heightConstraint: NSLayoutConstraint
    let readMoreButton = UIButton(type: .system)
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        heightConstraint = NSLayoutConstraint(item: whizzyWigView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: minHeight)
        heightConstraint.priority = 999.0
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none

        contentView.addSubview(whizzyWigView)

        let h = NSLayoutConstraint.constraints(withVisualFormat: "|[whizzy]|", options: [], metrics: nil, views: ["whizzy": whizzyWigView])
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[whizzy]|", options: [], metrics: nil, views: ["whizzy": whizzyWigView])
        
        contentView.addConstraints(h+v)
        whizzyWigView.addConstraint(heightConstraint)
        
        whizzyWigView.contentInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        whizzyWigView.contentFinishedLoading = { [weak self] in
            if let me = self {
                me.contentSizeDidChange()
            }
        }

        let readMore = NSLocalizedString("Read More", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "button to read more of the description")
        readMoreButton.setTitle(readMore, for: UIControlState())
        readMoreButton.translatesAutoresizingMaskIntoConstraints = false
        readMoreButton.addTarget(self, action: #selector(WhizzyWigTableViewCell.readMoreButtonWasTapped(_:)), for: .touchUpInside)
        readMoreButton.isHidden = true
        readMoreButton.backgroundColor = UIColor.white
        contentView.addSubview(readMoreButton)
        contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "|[readMore]|", options: [], metrics: nil, views: ["readMore": readMoreButton]))
        contentView.addConstraint(NSLayoutConstraint(
            item: readMoreButton,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: whizzyWigView,
            attribute: .bottom,
            multiplier: 1,
            constant: 0))
    }
    
    fileprivate func contentSizeDidChange() {
        let contentHeight = whizzyWigView.contentHeight
        heightConstraint.constant = min(maxHeight, max(minHeight, contentHeight))
        cellSizeUpdated(indexPath)
        if contentHeight > maxHeight && readMore != nil {
            readMoreButton.isHidden = false
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        heightConstraint = aDecoder.decodeObject(forKey: "heightConstraint") as! NSLayoutConstraint
        super.init(coder: aDecoder)
    }
    
    open override func encode(with aCoder: NSCoder) {
        aCoder.encode(indexPath, forKey: "indexPath")
        aCoder.encode(heightConstraint, forKey: "heightConstraint")
    }
    
    
    open var expectedHeight: CGFloat {
        get {
            return heightConstraint.constant
        }
        set {
            heightConstraint.constant = min(max(minHeight, newValue), maxHeight)
            contentView.setNeedsLayout()
        }
    }
    
    open override func prepareForReuse() {
        indexPath = IndexPath(row: 0, section: 0)
        cellSizeUpdated = {_ in }
        readMore = nil
    }

    open func readMoreButtonWasTapped(_ sender: UIButton) {
        let wwvc = WhizzyWigViewController(nibName: nil, bundle: nil)
        self.readMore?(wwvc)
    }
}

