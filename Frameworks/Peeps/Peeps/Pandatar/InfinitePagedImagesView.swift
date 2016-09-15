//
//  InfinitePagedImagesView.swift
//  iCanvas
//
//  Created by Ben Kraus on 5/4/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit

// This is a port of the old one from Obj-land in the realm of RealmKit
class InfinitePagedImagesView: UIScrollView {

    private var images: [UIImage] = []
    private var layedOut: Bool = false

    override var pagingEnabled: Bool {
        didSet {
            if !pagingEnabled {
                pagingEnabled = true
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

    func setup() {
        pagingEnabled = true
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

    func goToPage(page: Int, animated: Bool) {
        let page = page % images.count
        let newOffset = CGPoint(x: CGFloat(page+1)*bounds.size.width, y: 0)
        setContentOffset(newOffset, animated: animated)
    }

    func setImages(images: [UIImage]) {
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

            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: ceil(image.size.width)))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: ceil(image.size.height)))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: image.size.width/image.size.height, constant: 0.0))

            // The images won't necessarily fill up the whole width of one screen, so put them in a container
            let imageContainer = UIView()
            imageContainer.translatesAutoresizingMaskIntoConstraints = false
            imageContainer.addSubview(imageView)

            imageContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[image]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["image": imageView]))
            imageContainer.addConstraint(NSLayoutConstraint(item: imageContainer, attribute: .CenterX, relatedBy: .Equal, toItem: imageView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            imageContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=40)-[image]-(>=40)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["image": imageView]))

            addSubview(imageContainer)
            addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: imageContainer, attribute: .Height, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: imageContainer, attribute: .Width, multiplier: 1.0, constant: 0))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[container]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["container": imageContainer]))
            if let lastView = lastView {
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[last][container]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["last": lastView, "container": imageContainer]))
            } else {
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[container]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["container": imageContainer]))
            }
            lastView = imageContainer
        }

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[last]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["last": lastView!]))
    }
}
