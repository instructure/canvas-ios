//
//  SettingsObserveeCell.swift
//  Parent
//
//  Created by Brandon Pluim on 2/11/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class SettingsObserveeCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    var highlightColor = UIColor.whiteColor()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)

        stylize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        stylize()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.backgroundColor = selected ? highlightColor : UIColor.whiteColor()
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        self.backgroundColor = highlighted ? highlightColor : UIColor.whiteColor()
    }

    func stylize() {
        selectionStyle = .None
        
        guard let imageView = avatarImageView else {
            return
        }

        imageView.layer.cornerRadius = CGRectGetHeight(imageView.frame)/2
        imageView.clipsToBounds = true
        
        accessoryType = .DisclosureIndicator
    }

}
