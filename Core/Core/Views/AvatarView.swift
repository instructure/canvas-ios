//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

@IBDesignable
open class AvatarView: UIView {
    public let imageView = UIImageView()
    public let label = UILabel()

    open override func layoutSubviews() {
        // One time setup.
        if imageView.superview == nil {
            addSubview(imageView)
            imageView.pin(inside: self)
            imageView.backgroundColor = .named(.backgroundLight)
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.isAccessibilityElement = false
            imageView.tintColor = .named(.textDark)

            addSubview(label)
            label.pin(inside: self)
            label.allowsDefaultTighteningForTruncation = true
            label.backgroundColor = .named(.backgroundLightest)
            label.clipsToBounds = true
            label.isAccessibilityElement = false
            label.layer.borderColor = UIColor.named(.borderMedium).cgColor
            label.layer.borderWidth = 1 / UIScreen.main.scale
            label.lineBreakMode = .byClipping
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
            let url = AvatarView.scrubbedURL(self.url)
            imageView.load(url: url)
            label.isHidden = url != nil
        }
    }

    @IBInspectable
    public var name: String = "" {
        didSet {
            label.text = AvatarView.initials(for: name)
        }
    }

    static func scrubbedURL(_ url: URL?) -> URL? {
        // Ignore crappy default avatars.
        if url?.absoluteString.contains("images/dotted_pic.png") == true || url?.absoluteString.contains("images/messages/avatar-50.png") == true {
            return nil
        }
        return url
    }

    static func initials(for name: String) -> String {
        return name.split(separator: " ", maxSplits: 1).reduce("") { (value: String, part: Substring) -> String in
            guard let char = part.first else { return value }
            return "\(value)\(char)"
        }.localizedUppercase
    }
}
