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

internal let cellInset: CGFloat = 0.0
internal let borderWidth: CGFloat = 2.0
internal class BackdropCell: UICollectionViewCell {
    lazy fileprivate var imageView: UIImageView = {
        self.contentView.layer.borderWidth = borderWidth
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.backgroundColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(imageView)
        let metrics = ["in": cellInset]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-in-[image]-in-|", options: NSLayoutFormatOptions(), metrics: metrics, views: ["image": imageView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-in-[image]-in-|", options: NSLayoutFormatOptions(), metrics: metrics, views: ["image": imageView]))
        return imageView
    }()
    lazy fileprivate var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(progressView)
        let metrics = ["in": cellInset, "border": borderWidth]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-in-[progress]", options: NSLayoutFormatOptions(), metrics: metrics, views: ["progress": progressView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-in-[progress]-in-|", options: NSLayoutFormatOptions(), metrics: metrics, views: ["progress": progressView]))
        return progressView
    }()
    
    var image: UIImage? {
        set {
            self.imageView.isHidden = false
            self.progressView.isHidden = true
            self.imageView.image = newValue
        }
        get {
            return self.imageView.image
        }
    }

    var progress: Float {
        set {
            self.imageView.image = nil
            self.progressView.isHidden = false
            self.progressView.progress = newValue
        }
        get {
            return self.progressView.progress
        }
    }
    
}
