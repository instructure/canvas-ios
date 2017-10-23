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
import Cartography

class NextOrSubmitView: UIView {
    
    @IBOutlet var submitButton: UIButton!
    
    enum NextOrSubmit: Int {
        case next, submit
        
        var labelText: String {
            switch self {
            case .next:
                return NSLocalizedString("Next", tableName: "Localizable", bundle: .core, value: "", comment: "Next button for advancing a quiz")
            case .submit:
                return NSLocalizedString("Submit", tableName: "Localizable", bundle: .core, value: "", comment: "Submit button title")
            }
        }
    }
    
    var onNextOrSubmit: ()->() = {}
    
    func doNextOrSubmit(_ button: UIButton) {
        onNextOrSubmit()
    }
    
    class func createWithNextOrSubmit(_ nextOrSubmit: NextOrSubmit, target: Any?, action: Selector) -> NextOrSubmitView {
        let nib = UINib(nibName: "NextOrSubmitView", bundle: Bundle(for: NextOrSubmitView.classForCoder()))
        
        let me = nib.instantiate(withOwner: nil, options: nil).first as! NextOrSubmitView
        
        me.submitButton.setTitle(nextOrSubmit.labelText, for: UIControlState())
        me.submitButton.makeItBlue()
        me.submitButton.addTarget(target, action: action, for: .touchUpInside)
        
        return me
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
