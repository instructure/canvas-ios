//
//  MasteryPathAssignmentInfoCell.swift
//  Canvas
//
//  Created by Ben Kraus on 10/25/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit

class MasteryPathAssignmentInfoCell: UITableViewCell {

    @IBOutlet var contentStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var pointsPossibleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        let titleDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleTitle3).fontDescriptorWithSymbolicTraits(.TraitBold)!
        titleLabel.font = UIFont(descriptor: titleDescriptor, size: 0.0)
    }
}
