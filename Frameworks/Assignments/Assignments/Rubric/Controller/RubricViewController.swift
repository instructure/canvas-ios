//
//  RubricViewController.swift
//  Assignments
//
//  Created by Nathan Lambson on 3/23/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import AssignmentKit
import SoPersistent
import SoLazy
import TooLegit
import ReactiveCocoa
import SoPretty

// Mark: Custom Cells

class PointsPossibleCell: UITableViewCell {
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var pointsTitleLabel: UILabel!
}

class RubricCriterionRatingCell: UITableViewCell {
    @IBOutlet var descriptionOnlyHeight: NSLayoutConstraint!
    @IBOutlet var descriptionAndCommentHeight: NSLayoutConstraint!
    @IBOutlet var lineViewHeight: NSLayoutConstraint!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
}

// Mark: View Controller

class RubricViewController: Rubric.DetailViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 
    static func new(session: Session, courseID: String, assignmentID: String) throws -> RubricViewController {
        guard let me = UIStoryboard(name: "Rubric", bundle: NSBundle(forClass: self)).instantiateInitialViewController() as? RubricViewController else {
            fatalError()
        }
        
        let observer = try Rubric.observer(session, courseID: courseID, assignmentID: assignmentID)
        let refresher = try Rubric.refresher(session, courseID: courseID, assignmentID: assignmentID)
        
        me.prepare(observer, refresher: refresher, detailsFactory: RubricCellViewModel.rubricDetails(session.baseURL))
        
        return me
    }
}
