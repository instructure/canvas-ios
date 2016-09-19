//
//  SettingDetailCell.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/15/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoPersistent

class SettingDetailCell: ColorfulTableViewCell, DetailCell {
    @IBOutlet var paddingConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingLabel: UILabel!

    override func updateColor(color: UIColor) {
        super.updateColor(color)
        settingLabel?.textColor = color
    }
}
