//
//  DetailsDescriptionCell.swift
//  Parent
//
//  Created by Ben Kraus on 3/2/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import WhizzyWig

class DetailsDescriptionCell: WhizzyWigTableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        whizzyWigView.backgroundColor = UIColor.clearColor()
        whizzyWigView.contentFontColor = UIColor(r: 102.0, g: 102.0, b: 102.0)
        whizzyWigView.contentInsets = UIEdgeInsets(top: 14.0, left: 51.0, bottom: 14.0, right: 15.0)

        setupIcon()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupIcon() {
        let icon = UIImage(named: "icon_document")
        let iconImageView = UIImageView(image: icon)
        iconImageView.contentMode = .ScaleAspectFit
        iconImageView.tintColor = UIColor(r: 180.0, g: 180.0, b: 180.0)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)

        let views = ["iconImageView": iconImageView, "whizzyWigView": whizzyWigView]
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-padding-[iconImageView(iconHeight)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["padding": 10, "iconHeight": 28], views: views)
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-padding-[iconImageView(iconWidth)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["padding": 12, "iconWidth": 31], views: views)

        contentView.addConstraints(verticalConstraints)
        contentView.addConstraints(horizontalConstraints)
    }

}