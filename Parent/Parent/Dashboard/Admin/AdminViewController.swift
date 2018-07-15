//
// Copyright (C) 2018-present Instructure, Inc.
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
