//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation

@IBDesignable
open class EmptyView: UIView {
    @IBOutlet weak var titleLabel: DynamicLabel?
    @IBOutlet weak var bodyLabel: DynamicLabel?
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint?

    @IBInspectable
    public var titleText: String? {
        get { return titleLabel?.text }
        set { titleLabel?.text = newValue }
    }

    @IBInspectable
    public var bodyText: String? {
        get { return bodyLabel?.text }
        set { bodyLabel?.text = newValue }
    }

    @IBInspectable
    public var imageWidth: CGFloat {
        get { return imageViewWidthConstraint?.constant ?? 0 }
        set { imageViewWidthConstraint?.constant = newValue }
    }

    @IBInspectable
    public var imageHeight: CGFloat {
        get { return imageViewHeightConstraint?.constant ?? 0 }
        set { imageViewHeightConstraint?.constant = newValue }
    }

    @IBInspectable
    public var imageName: String = "" {
        didSet {
            if let icon = UIImage(named: imageName, in: .core, compatibleWith: nil) {
                image = icon
            }
        }
    }

    public var image: UIImage? {
        get { return imageView?.image }
        set { imageView?.image = newValue }
    }

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        loadFromXib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
}
