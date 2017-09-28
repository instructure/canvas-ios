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

class NoResultsView : UIView {
    
    @IBOutlet weak var lblExplanation: UILabel!
    
    class func instantiateFromNib(_ explanation: String) -> NoResultsView? {
        if let noResultsView = NoResultsView.loadFromNibNamed("NoResultsView", bundle: NoResultsView.bundle) as? NoResultsView {
            
            noResultsView.backgroundColor = UIColor.clear
            
            noResultsView.lblExplanation.textColor = UIColor.calendarNoResultsTextColor
            noResultsView.lblExplanation.text = explanation
            noResultsView.lblExplanation.adjustsFontSizeToFitWidth = true
            noResultsView.lblExplanation.font = UIFont.preferredFont(forTextStyle: .body).noLargerThan(28.0)
            return noResultsView
        }
        
        return nil
    }

}
