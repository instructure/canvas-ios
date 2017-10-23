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
import CanvasCore

class TriangleGradientNavigationBar: UINavigationBar {

    fileprivate var topTintColor: UIColor?
    fileprivate var bottomTintColor: UIColor?
    fileprivate var oldSize = CGSize.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        isTranslucent = false
        barStyle = .black
        shadowImage = UIImage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !bounds.size.equalTo(oldSize) {
            redrawBackgroundImage()
            oldSize = bounds.size
        }
    }

    func transitionToColors(_ topTintColor: UIColor?, bottomTintColor: UIColor?) {
        self.topTintColor = topTintColor
        self.bottomTintColor = bottomTintColor
        redrawBackgroundImage()
    }

    func redrawBackgroundImage() {
        guard let topTintColor = topTintColor, let bottomTintColor = bottomTintColor else { return }

        let screenSize: CGRect = UIScreen.main.bounds
        let triangleBackgroundView = TriangleBackgroundGradientView(frame: screenSize, tintTopColor: topTintColor, tintBottomColor: bottomTintColor)

        UIGraphicsBeginImageContextWithOptions(triangleBackgroundView.frame.size, triangleBackgroundView.isOpaque, 0.0)
        triangleBackgroundView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setBackgroundImage(img, for: UIBarMetrics.default)
    }

}
