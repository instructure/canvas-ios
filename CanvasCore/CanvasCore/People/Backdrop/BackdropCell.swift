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
