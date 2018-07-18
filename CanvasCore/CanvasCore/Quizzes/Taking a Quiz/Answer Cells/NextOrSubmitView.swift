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
