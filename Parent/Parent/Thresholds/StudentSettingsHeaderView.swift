//
//  StudentSettingsHeaderView.swift
//  Parent
//
//  Created by Brandon Pluim on 6/17/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

public class StudentSettingsHeaderView: UIView {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!

    public override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.cornerRadius = CGRectGetHeight(imageView.frame)/2
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.borderWidth = 2.0
        imageView.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFit
    }
    
}
