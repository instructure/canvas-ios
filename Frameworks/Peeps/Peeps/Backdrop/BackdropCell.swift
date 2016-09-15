//
//  BackdropCell.swift
//  iCanvas
//
//  Created by Nathan Perry on 7/1/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

internal let cellInset: CGFloat = 0.0
internal let borderWidth: CGFloat = 2.0
internal class BackdropCell: UICollectionViewCell {
    lazy private var imageView: UIImageView = {
        self.contentView.layer.borderWidth = borderWidth
        let imageView = UIImageView(frame: CGRectZero)
        imageView.backgroundColor = UIColor.lightGrayColor()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(imageView)
        let metrics = ["in": cellInset]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-in-[image]-in-|", options: NSLayoutFormatOptions(), metrics: metrics, views: ["image": imageView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-in-[image]-in-|", options: NSLayoutFormatOptions(), metrics: metrics, views: ["image": imageView]))
        return imageView
    }()
    lazy private var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(progressView)
        let metrics = ["in": cellInset, "border": borderWidth]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-in-[progress]", options: NSLayoutFormatOptions(), metrics: metrics, views: ["progress": progressView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-in-[progress]-in-|", options: NSLayoutFormatOptions(), metrics: metrics, views: ["progress": progressView]))
        return progressView
    }()
    
    var image: UIImage? {
        set {
            self.imageView.hidden = false
            self.progressView.hidden = true
            self.imageView.image = newValue
        }
        get {
            return self.imageView.image
        }
    }

    var progress: Float {
        set {
            self.imageView.image = nil
            self.progressView.hidden = false
            self.progressView.progress = newValue
        }
        get {
            return self.progressView.progress
        }
    }
    
}