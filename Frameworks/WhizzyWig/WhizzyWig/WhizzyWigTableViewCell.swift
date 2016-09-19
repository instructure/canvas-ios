//
//  WhizzyWigTableViewCell.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 12/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit

public class WhizzyWigTableViewCell: UITableViewCell {
    
    public var indexPath = NSIndexPath(forRow: 0, inSection: 0)
    public var cellSizeUpdated: NSIndexPath->() = {_ in }
    public var readMore: (WhizzyWigViewController->())? {
        didSet {
            readMoreButton.hidden = readMore == nil || whizzyWigView.contentHeight <= maxHeight
        }
    }
    
    var minHeight: CGFloat = 0.0
    var maxHeight: CGFloat = 6144.0
    
    public let whizzyWigView = WhizzyWigView(frame: CGRect(x: 0, y: 0, width: 320, height: 43))
    
    let heightConstraint: NSLayoutConstraint
    let readMoreButton = UIButton(type: .System)
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        heightConstraint = NSLayoutConstraint(item: whizzyWigView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: minHeight)
        heightConstraint.priority = 999.0
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None

        contentView.addSubview(whizzyWigView)

        let h = NSLayoutConstraint.constraintsWithVisualFormat("|[whizzy]|", options: [], metrics: nil, views: ["whizzy": whizzyWigView])
        let v = NSLayoutConstraint.constraintsWithVisualFormat("V:|[whizzy]|", options: [], metrics: nil, views: ["whizzy": whizzyWigView])
        
        contentView.addConstraints(h+v)
        whizzyWigView.addConstraint(heightConstraint)
        
        whizzyWigView.contentInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        whizzyWigView.contentFinishedLoading = { [weak self] in
            if let me = self {
                me.contentSizeDidChange()
            }
        }

        let readMore = NSLocalizedString("Read More", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "button to read more of the description")
        readMoreButton.setTitle(readMore, forState: .Normal)
        readMoreButton.translatesAutoresizingMaskIntoConstraints = false
        readMoreButton.addTarget(self, action: "readMoreButtonWasTapped:", forControlEvents: .TouchUpInside)
        readMoreButton.hidden = true
        readMoreButton.backgroundColor = UIColor.whiteColor()
        contentView.addSubview(readMoreButton)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "|[readMore]|", options: [], metrics: nil, views: ["readMore": readMoreButton]))
        contentView.addConstraint(NSLayoutConstraint(
            item: readMoreButton,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: whizzyWigView,
            attribute: .Bottom,
            multiplier: 1,
            constant: 0))
    }
    
    private func contentSizeDidChange() {
        let contentHeight = whizzyWigView.contentHeight
        heightConstraint.constant = min(maxHeight, max(minHeight, contentHeight))
        cellSizeUpdated(indexPath)
        if contentHeight > maxHeight && readMore != nil {
            readMoreButton.hidden = false
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        heightConstraint = aDecoder.decodeObjectForKey("heightConstraint") as! NSLayoutConstraint
        super.init(coder: aDecoder)
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(indexPath, forKey: "indexPath")
        aCoder.encodeObject(heightConstraint, forKey: "heightConstraint")
    }
    
    
    public var expectedHeight: CGFloat {
        get {
            return heightConstraint.constant
        }
        set {
            heightConstraint.constant = min(max(minHeight, newValue), maxHeight)
            contentView.setNeedsLayout()
        }
    }
    
    public override func prepareForReuse() {
        indexPath = NSIndexPath(forRow: 0, inSection: 0)
        cellSizeUpdated = {_ in }
        readMore = nil
    }

    public func readMoreButtonWasTapped(sender: UIButton) {
        let wwvc = WhizzyWigViewController(nibName: nil, bundle: nil)
        self.readMore?(wwvc)
    }
}

