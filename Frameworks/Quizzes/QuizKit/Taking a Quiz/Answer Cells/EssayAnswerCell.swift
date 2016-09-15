//
//  EssayAnswerCell.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 2/18/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import WhizzyWig
import Cartography
import SoPretty


class EssayAnswerCell: WhizzyTextInputCell {
    class var ReuseID: String {
        return "EssayAnswerCellReuseID"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        placeholder.text = "Enter answer..."
        
        textView.layer.borderColor = UIColor.prettyLightGray().CGColor
        textView.layer.borderWidth = 2.0
        
        tintColor = Brand.current().tintColor
        
        accessibilityElements = [textView]
        isAccessibilityElement = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        inputText = ""
    }
}