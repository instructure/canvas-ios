//
//  UIPickerView+Quiz.swift
//  CanvasCore
//
//  Created by Layne Moseley on 4/17/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

let sizingLabel = UILabel()

extension UIPickerView {
    
    // Measures all of the titles and returns the height of the tallest one
    func heightForTitles(titles: [String]) -> CGFloat {
        sizingLabel.numberOfLines = 0
        let width = self.frame.width
        return titles.reduce(0.0, { (memo, value) -> CGFloat in
            sizingLabel.text = value
            let height = sizingLabel.sizeThatFits(CGSize(width: width, height: CGFloat(Int.max))).height
            if (height > memo) {
                return height
            }
            
            return memo
        })
    }
    
    func titleView(title: String) -> UIView {
        let label = UILabel()
        label.text = title
        label.numberOfLines = 0
        label.textAlignment = .left
        let size = label.sizeThatFits(CGSize(width: self.frame.width, height: CGFloat(Int.max)))
        label.frame.size = CGSize(width: self.frame.width - 20.0, height: size.height)
        return label
    }
}
