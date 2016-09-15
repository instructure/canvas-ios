//
//  CourseGradesTableViewCell.swift
//  Enrollments
//
//  Created by Brandon Pluim on 1/22/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class CourseCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!

    var highlightColor = UIColor.whiteColor()

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.backgroundColor = selected ? highlightColor : UIColor.whiteColor()
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        contentView.backgroundColor = highlighted ? highlightColor : UIColor.whiteColor()
    }
    
}
