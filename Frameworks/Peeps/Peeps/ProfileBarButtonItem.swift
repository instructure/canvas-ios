//
//  ProfileBarButtonItem.swift
//  iCanvas
//
//  Created by Ben Kraus on 5/9/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import Kingfisher

public class ProfileBarButtonItem: UIBarButtonItem {
    private var button: UIButton!

    public convenience init(avatarURL: NSURL?) {
        let button = UIButton()

        let buttonDiameter: CGFloat = 30
        button.frame = CGRect(x: 0, y: 0, width: buttonDiameter, height: buttonDiameter)
        button.layer.cornerRadius = buttonDiameter/2.0
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.grayColor().CGColor
        button.tintColor = UIColor.whiteColor()
        button.accessibilityLabel = NSLocalizedString("Profile", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "Accessibility label for the profile button")
        button.accessibilityHint = NSLocalizedString("Opens profile", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "Accessibility hint for the profile button")

        let wrapper = UIView(frame: CGRect(x: 0, y: 0, width: buttonDiameter, height: buttonDiameter))
        wrapper.addSubview(button)
        self.init(customView: wrapper)

        self.button = button

        let placeholderImage = UIImage(named: "icon_user")
        if let avatarURL = avatarURL {
            button.kf_setImageWithURL(avatarURL, forState: .Normal, placeholderImage: placeholderImage)
        } else {
            button.setImage(placeholderImage, forState: .Normal)
        }

        button.addTarget(self, action: #selector(ProfileBarButtonItem.showProfile(_:)), forControlEvents: .TouchUpInside)
    }

    private override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setProfileImage(image: UIImage?) {
        button.setImage(image, forState: .Normal)
    }

    func showProfile(button: UIButton) {
        target?.performSelector(action, withObject: self)
    }
}