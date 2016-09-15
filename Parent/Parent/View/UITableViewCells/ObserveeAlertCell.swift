//
//  ObserveeAlertCell.swift
//  ObserverAlertKit
//
//  Created by Ben Kraus on 2/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit

class ObserveeAlertCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
