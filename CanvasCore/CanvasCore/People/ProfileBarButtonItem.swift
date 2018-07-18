//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
