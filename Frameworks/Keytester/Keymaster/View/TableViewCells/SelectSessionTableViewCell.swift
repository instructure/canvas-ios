//
//  SelectSessionCell.swift
//  Keymaster
//
//  Created by Brandon Pluim on 1/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit

import TooLegit
import SoPretty

class SelectSessionTableViewCell: UITableViewCell {
    
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
                self.nameLabel.text = session.user.name
                self.domainLabel.text = session.baseURL.host
                
                self.avatarImageView.image = nil
                if let avatarURL = session.user.avatarURL {
                    self.avatarImageView.downloadedFrom(avatarURL, contentMode: .ScaleAspectFit)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.avatarImageView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.bounds)/2
        self.avatarImageView.clipsToBounds = true
        
        self.nameLabel.textColor = UIColor.darkTextColor()
        self.domainLabel.textColor = UIColor.lightGrayColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            
        } else {
            
        }
    }
    
}
