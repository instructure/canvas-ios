//
//  AccountDomainTableViewCell.swift
//  Keymaster
//
//  Created by Brandon Pluim on 12/4/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit

class AccountDomainTableViewCell: UITableViewCell {
    
    // ---------------------------------------------
    // MARK: - SubViews
    // ---------------------------------------------
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var domainLabel: UILabel!
    
    var domain: AccountDomain? {
        didSet {
            if let domain = domain {
                self.nameLabel.text = domain.name
                self.domainLabel.text = domain.domain
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
