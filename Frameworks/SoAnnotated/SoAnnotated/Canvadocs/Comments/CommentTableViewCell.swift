//
//  CommentTableViewCell.swift
//  SoAnnotated
//
//  Created by Ben Kraus on 10/28/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .None
    }
}

