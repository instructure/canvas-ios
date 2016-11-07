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
