//
//  DetailsAttachmentCell.swift
//  Parent
//
//  Created by Ben Kraus on 9/14/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class DetailsAttachmentCell: UITableViewCell {

    @IBOutlet var filenameLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Because Xcode is being dumb and isn't picking it up from what it is set in the nib
        iconImageView.tintColor = UIColor(r: 180.0, g: 180.0, b: 180.0)
        filenameLabel.accessibilityIdentifier = "event_detail_attachment"
    }    
}
