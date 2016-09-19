//
//  HeadingDetailCell.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/15/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoPretty

class HeadingDetailCell: UITableViewCell, DetailCell {
    @IBOutlet var paddingConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var headingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headingLabel.textColor = .prettyGray()
    }
}
