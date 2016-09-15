//
//  QuestionDrawerCell.swift
//  Quizzes
//
//  Created by Ben Kraus on 3/16/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import SoPretty

enum QuestionCellState: Int {
    case Flagged
    case Answered
    case Untouched
}

class QuestionDrawerCell: UITableViewCell {

    @IBOutlet var statusIconView: UIImageView!
    @IBOutlet var questionTextLabel: UILabel!
    
    class var ReuseID: String {
        return "QuestionDrawerCell"
    }
    
    class var Nib: UINib {
        return UINib(nibName: "QuestionDrawerCell", bundle: NSBundle(forClass: self.classForCoder()))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusIconView.tintColor = Brand.current().secondaryTintColor
    }
    
    func displayState(state: QuestionCellState) {
        switch state {
        case .Flagged:
            let flagImage = UIImage(named: "flag_selected", inBundle: NSBundle(forClass: QuestionDrawerCell.self), compatibleWithTraitCollection: nil)
            statusIconView.image = flagImage
        case .Answered:
            let checkImage = UIImage(named: "check", inBundle: NSBundle(forClass: QuestionDrawerCell.self), compatibleWithTraitCollection: nil)
            statusIconView.image = checkImage
        case .Untouched:
            statusIconView.image = nil
        }
    }
}
