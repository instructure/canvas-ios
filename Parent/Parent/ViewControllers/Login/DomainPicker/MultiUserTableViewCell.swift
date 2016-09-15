//
//  MultiUserTableViewCell.swift
//  Keymaster
//
//  Created by Brandon Pluim on 12/2/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit

import TooLegit

class MultiUserTableViewCell: UITableViewCell {
    
    // ---------------------------------------------
    // MARK: - SubViews
    // ---------------------------------------------
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var domainLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var deleteButton: UIButton!
    
    var session: Session? {
        didSet {
            if let session = session {
                self.nameLabel.text = session.currentUser.name
                self.domainLabel.text = session.auth.url.absoluteString
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // TODO: Set Selected State
        // Configure the view for the selected state
        if selected {
            
        } else {
            
        }
    }

}
