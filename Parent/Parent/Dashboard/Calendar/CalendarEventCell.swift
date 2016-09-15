//
//  CalendarEventTableViewCell.swift
//  Calendar
//
//  Created by Brandon Pluim on 1/21/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class CalendarEventCell: UITableViewCell {

    static let iconImageDiameter: CGFloat = 36.0
    static let iconSubtrator: CGFloat = 15.0
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var statusLabel: TokenLabelView!

    var highlightColor = UIColor.whiteColor()

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .None
        typeImageView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        typeImageView.layer.cornerRadius = CGRectGetHeight(typeImageView.frame)/2
        statusLabel.layer.cornerRadius = CGRectGetHeight(statusLabel.frame)/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.backgroundColor = selected ? highlightColor : UIColor.whiteColor()
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        contentView.backgroundColor = highlighted ? highlightColor : UIColor.whiteColor()
    }
    
}