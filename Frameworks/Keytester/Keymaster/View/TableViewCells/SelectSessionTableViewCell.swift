//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
