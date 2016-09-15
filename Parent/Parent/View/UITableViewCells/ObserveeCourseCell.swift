//
//  CourseGradesTableViewCell.swift
//  Enrollments
//
//  Created by Brandon Pluim on 1/22/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class ObserveeCourseCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var currentGradeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
