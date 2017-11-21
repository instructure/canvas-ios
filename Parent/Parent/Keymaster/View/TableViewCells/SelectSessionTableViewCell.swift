//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import CanvasCore

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
                    self.avatarImageView.downloadedFrom(avatarURL, contentMode: .scaleAspectFit)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.height/2
        self.avatarImageView.clipsToBounds = true
        
        self.nameLabel.textColor = UIColor.darkText
        self.domainLabel.textColor = UIColor.lightGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            
        } else {
            
        }
    }
    
}
