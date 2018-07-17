//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation

class AdminViewController : UIViewController {
    @IBOutlet weak var actAsUserButton: UIButton!
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var actAsUserHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        welcomeLabel.text = NSLocalizedString("Welcome!", comment: "Header title of admin view")
        directionsLabel.text = NSLocalizedString("Tap to start viewing Canvas as another person.", comment: "Directions in the admin view")
        
        actAsUserButton.titleLabel?.text = NSLocalizedString("Act as User", comment: "Label for button that allows admin to Act as User")
        actAsUserButton.layer.cornerRadius = 5
        actAsUserButton.clipsToBounds = true
    }
    
    @IBAction func actAsUserTapped(_ sender: UIButton) {
        actAsUserHandler?()
    }
}
