//
//  GradientTriangleNavigationBar.swift
//  Parent
//
//  Created by Ben Kraus on 2/26/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import SoPretty

class TriangleGradientNavigationBar: UINavigationBar {

    private var topTintColor: UIColor?
    private var bottomTintColor: UIColor?
    private var oldSize = CGSizeZero

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        translucent = false
        barStyle = .Black
        shadowImage = UIImage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !CGSizeEqualToSize(bounds.size, oldSize) {
            redrawBackgroundImage()
            oldSize = bounds.size
        }
    }

    func transitionToColors(topTintColor: UIColor?, bottomTintColor: UIColor?) {
        self.topTintColor = topTintColor
        self.bottomTintColor = bottomTintColor
        redrawBackgroundImage()
    }

    func redrawBackgroundImage() {
        guard let topTintColor = topTintColor, bottomTintColor = bottomTintColor else { return }

        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let triangleBackgroundView = TriangleBackgroundGradientView(frame: screenSize, tintTopColor: topTintColor, tintBottomColor: bottomTintColor)

        UIGraphicsBeginImageContextWithOptions(triangleBackgroundView.frame.size, triangleBackgroundView.opaque, 0.0)
        triangleBackgroundView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setBackgroundImage(img, forBarMetrics: UIBarMetrics.Default)
    }

}
