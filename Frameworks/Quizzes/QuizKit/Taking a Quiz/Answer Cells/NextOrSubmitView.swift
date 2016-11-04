
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
        case Next, Submit
        
        var labelText: String {
            switch self {
            case .Next:
                return NSLocalizedString("Next", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Next button for advancing a quiz")
            case .Submit:
                return NSLocalizedString("Submit", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Submit button title")
            }
        }
    }
    
    var onNextOrSubmit: ()->() = {}
    
    func doNextOrSubmit(button: UIButton) {
        onNextOrSubmit()
    }
    
    class func createWithNextOrSubmit(nextOrSubmit: NextOrSubmit, target: AnyObject?, action: Selector) -> NextOrSubmitView {
        let nib = UINib(nibName: "NextOrSubmitView", bundle: NSBundle(forClass: NextOrSubmitView.classForCoder()))
        
        let me = nib.instantiateWithOwner(nil, options: nil).first as! NextOrSubmitView
        
        me.submitButton.setTitle(nextOrSubmit.labelText, forState: .Normal)
        me.submitButton.makeItBlue()
        me.submitButton.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        
        return me
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
