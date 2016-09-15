//
//  QuizDetailCell.swift
//  Quizzes
//
//  Created by Ben Kraus on 3/9/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

class QuizDetailCell: UITableViewCell {
    
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    class var Nib: UINib {
        return UINib(nibName: "QuizDetailCell", bundle: NSBundle(forClass: self.classForCoder()))
    }
    
    class var ReuseID: String {
        return "QuizDetailCell"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
