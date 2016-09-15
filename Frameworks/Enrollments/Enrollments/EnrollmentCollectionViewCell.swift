//
//  EnrollmentCollectionViewCell.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 2/16/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import EnrollmentKit
import ReactiveCocoa

public class EnrollmentCollectionViewCell: EnrollmentKit.EnrollmentCollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    
    var customize: ()->() = {}
    
    @IBAction func customize(sender: AnyObject) {
        customize()
    }
}
