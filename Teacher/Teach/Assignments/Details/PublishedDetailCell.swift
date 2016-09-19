//
//  PublishedDetailCell.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/15/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoPersistent


class PublishedDetailCell: ColorfulTableViewCell, DetailCell {
    @IBOutlet var paddingConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
}
