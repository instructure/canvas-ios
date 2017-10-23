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
import Kingfisher

open class ProfileBarButtonItem: UIBarButtonItem {
    fileprivate var button: UIButton!

    public convenience init(avatarURL: URL?) {
        let button = UIButton()

        let buttonDiameter: CGFloat = 30
        button.frame = CGRect(x: 0, y: 0, width: buttonDiameter, height: buttonDiameter)
        button.layer.cornerRadius = buttonDiameter/2.0
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.gray.cgColor
        button.tintColor = UIColor.white
        button.accessibilityLabel = NSLocalizedString("Profile", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "Accessibility label for the profile button")
        button.accessibilityHint = NSLocalizedString("Opens profile", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "Accessibility hint for the profile button")

        let wrapper = UIView(frame: CGRect(x: 0, y: 0, width: buttonDiameter, height: buttonDiameter))
        wrapper.addSubview(button)
        self.init(customView: wrapper)

        self.button = button

        let placeholderImage = UIImage(named: "icon_user")
        if let avatarURL = avatarURL {
            button.kf.setImage(with: avatarURL, for: .normal, placeholder: placeholderImage)
        } else {
            button.setImage(placeholderImage, for: UIControlState())
        }

        button.addTarget(self, action: #selector(ProfileBarButtonItem.showProfile(_:)), for: .touchUpInside)
    }

    fileprivate override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setProfileImage(_ image: UIImage?) {
        button.setImage(image, for: UIControlState())
    }

    func showProfile(_ button: UIButton) {
        let _ = target?.perform(action, with: self)
    }
}
