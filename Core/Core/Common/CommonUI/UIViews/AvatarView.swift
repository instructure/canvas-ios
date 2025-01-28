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
    public var url: URL? {
        didSet {
            let url = Avatar.scrubbedURL(self.url)
            sendSubviewToBack(imageView)
            imageView.backgroundColor = .backgroundLight
            imageView.contentMode = .scaleAspectFill
            imageView.load(url: url)
            label.isHidden = url != nil
        }
    }

    @IBInspectable
    public var name: String = "" {
        didSet {
            label.text = Avatar.initials(for: name)
        }
    }

    public var icon: UIImage? {
        get { imageView.image }
        set {
            bringSubviewToFront(imageView)
            imageView.backgroundColor = nil
            imageView.contentMode = .center
            imageView.image = newValue
            label.text = ""
            label.isHidden = false
        }
    }

    private let imageView = AvatarView.makeimageView()
    private let label = AvatarView.makeLabel()
    private var frameChangeObservation: NSKeyValueObservation?

    // MARK: - Initializers

    public init() {
        super.init(frame: .null)
        addSubViews()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubViews()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
    }

    // MARK: - Private Methods

    private func addSubViews() {
        addSubview(imageView)
        imageView.pin(inside: self)

        addSubview(label)
        label.pin(inside: self)

        updateSubviews()

        frameChangeObservation = observe(\.bounds) { [weak self] _, _ in
            self?.updateSubviews()
        }
    }

    private func updateSubviews() {
        label.font = .systemFont(ofSize: round(frame.width / 2.25), weight: .semibold)
        label.layer.cornerRadius = frame.width / 2
        imageView.layer.cornerRadius = frame.width / 2
    }

    private static func makeLabel() -> UILabel {
        let label = UILabel()
        label.allowsDefaultTighteningForTruncation = true
        label.backgroundColor = .backgroundLightest
        label.clipsToBounds = true
        label.isAccessibilityElement = false
        label.layer.borderColor = UIColor.borderMedium.cgColor
        label.layer.borderWidth = 1 / UIScreen.main.scale
        label.lineBreakMode = .byClipping
        label.textAlignment = .center
        label.textColor = .textDark
        return label
    }

    public static func makeimageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .backgroundLight
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isAccessibilityElement = false
        imageView.tintColor = .textDark
        return imageView
    }
}
