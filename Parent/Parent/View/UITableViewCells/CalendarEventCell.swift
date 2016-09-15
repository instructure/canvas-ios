//
//  CalendarEventTableViewCell.swift
//  Calendar
//
//  Created by Brandon Pluim on 1/21/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class CalendarEventCell: UITableViewCell {
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
