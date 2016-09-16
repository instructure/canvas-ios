//
//  NoResultsView.swift
//  iCanvas
//
//  Created by Brandon Pluim on 6/4/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

class NoResultsView : UIView {
    
    @IBOutlet weak var lblExplanation: UILabel!
    
    class func instantiateFromNib(explanation: String) -> NoResultsView? {
        if let noResultsView = NoResultsView.loadFromNibNamed("NoResultsView", bundle: NoResultsView.bundle) as? NoResultsView {
            
            noResultsView.backgroundColor = UIColor.clearColor()
            
            noResultsView.lblExplanation.textColor = UIColor.calendarNoResultsTextColor
            noResultsView.lblExplanation.text = explanation
            return noResultsView
        }
        
        return nil
    }

}
