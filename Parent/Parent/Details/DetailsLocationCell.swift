//
//  DetailsLocationCell.swift
//  Parent
//
//  Created by Ben Kraus on 9/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class DetailsLocationCell: UITableViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var locationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Because Xcode is being dumb and isn't picking it up from what it is set in the nib
        iconImageView.tintColor = UIColor(r: 180.0, g: 180.0, b: 180.0)
        locationLabel.accessibilityIdentifier = "event_detail_location"
    }
}
