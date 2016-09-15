//
//  DashboardTabView.swift
//  Parent
//
//  Created by Brandon Pluim on 1/12/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class DashboardTabView: UIView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var normalImage: UIImage?
    var selectedImage: UIImage?
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.tintColor = UIColor.whiteColor()
        titleLabel.textColor = UIColor.whiteColor()
    }
    
    func setSelected(selected: Bool) {
        iconImageView.image = selected ? selectedImage : normalImage
    }
}
