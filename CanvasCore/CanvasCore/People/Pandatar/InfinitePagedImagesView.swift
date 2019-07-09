//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

// This is a port of the old one from Obj-land in the realm of RealmKit
class InfinitePagedImagesView: UIScrollView {

    fileprivate var images: [UIImage] = []
    fileprivate var layedOut: Bool = false

    override var isPagingEnabled: Bool {
        didSet {
            if !isPagingEnabled {
                isPagingEnabled = true
            }
        }
    }

    override var contentOffset: CGPoint {
        didSet {
            guard images.count >= 1 else { return }
            if contentOffset.x <= 0 {
                goToPage(images.count - 1, animated: false)
            } else if contentOffset.x >= contentSize.width - bounds.size.width {
                goToPage(0, animated: false)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    @objc func setup() {
        isPagingEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        showsHorizontalScrollIndicator = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !layedOut {
            goToPage(0, animated: false)
            layedOut = true
        }
    }

    @objc func goToPage(_ page: Int, animated: Bool) {
        let page = page % images.count
        let newOffset = CGPoint(x: CGFloat(page+1)*bounds.size.width, y: 0)
        setContentOffset(newOffset, animated: animated)
    }

    @objc func setImages(_ images: [UIImage]) {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        self.images = images

        var lastView: UIView? = nil

        guard images.count >= 1 else { return }
        let wrappedImages: [UIImage] = [images.last!] + images + [images.first!]
        for image in wrappedImages {
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.clipsToBounds = true
            imageView.isAccessibilityElement = true

            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: ceil(image.size.width)))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: ceil(image.size.height)))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: image.size.width/image.size.height, constant: 0.0))

            // The images won't necessarily fill up the whole width of one screen, so put them in a container
            let imageContainer = UIView()
            imageContainer.translatesAutoresizingMaskIntoConstraints = false
            imageContainer.addSubview(imageView)

            imageContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[image]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["image": imageView]))
            imageContainer.addConstraint(NSLayoutConstraint(item: imageContainer, attribute: .centerX, relatedBy: .equal, toItem: imageView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            imageContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=40)-[image]-(>=40)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["image": imageView]))

            addSubview(imageContainer)
            addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: imageContainer, attribute: .height, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: imageContainer, attribute: .width, multiplier: 1.0, constant: 0))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[container]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["container": imageContainer]))
            if let lastView = lastView {
                addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[last][container]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["last": lastView, "container": imageContainer]))
            } else {
                addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["container": imageContainer]))
            }
            lastView = imageContainer
        }

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[last]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["last": lastView!]))
    }
}
