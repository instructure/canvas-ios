//
// Copyright (C) 2019-present Instructure, Inc.
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

@IBDesignable
open class AvatarView: UIView {
    let imageView = UIImageView()
    let label = UILabel()

    open override func layoutSubviews() {
        // One time setup.
        if imageView.superview == nil {
            addSubview(imageView)
            imageView.pin(inside: self)
            imageView.backgroundColor = .named(.backgroundLight)
            imageView.clipsToBounds = true
            imageView.isAccessibilityElement = false
            imageView.tintColor = .named(.textDark)

            addSubview(label)
            label.pin(inside: self)
            label.backgroundColor = .named(.backgroundLightest)
            label.clipsToBounds = true
            label.isAccessibilityElement = false
            label.layer.borderColor = UIColor.named(.borderMedium).cgColor
            label.layer.borderWidth = 1 / UIScreen.main.scale
            label.textAlignment = .center
            label.textColor = .named(.textDark)
        }

        // Size dependent layout needs to happen every time.
        label.font = .systemFont(ofSize: round(frame.width / 2.25), weight: .semibold)
        label.layer.cornerRadius = frame.width / 2
        imageView.layer.cornerRadius = frame.width / 2

        super.layoutSubviews()
    }

    public var url: URL? {
        didSet {
            // Ignore crappy default avatars.
            var url = self.url
            if url?.absoluteString.contains("images/dotted_pic.png") == true || url?.absoluteString.contains("images/messages/avatar-50.png") == true {
                url = nil
            }

            imageView.load(url: url)
            label.isHidden = url != nil
        }
    }

    @IBInspectable
    public var name: String = "" {
        didSet {
            label.text = name.split(separator: " ", maxSplits: 2).reduce("") { (value: String, part: Substring) -> String in
                guard let char = part.first else { return value }
                return "\(value)\(char)"
            }.localizedUppercase
        }
    }
}
