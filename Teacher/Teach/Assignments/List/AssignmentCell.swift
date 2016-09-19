//
//  AssignmentCell.swift
//  Teach
//
//  Created by Derrick Hathaway on 6/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoPretty
import ReactiveCocoa

class AssignmentCell: UITableViewCell {
    
    @IBOutlet private weak var icon: UIImageView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    
    func prepare(iconImage: UIImage, iconA11yLabel: String, title: String, subtitle: String) {
        icon?.image = iconImage
        titleLabel?.text = title
        subtitleLabel?.text = subtitle
        
        accessibilityLabel = title + " — " + iconA11yLabel + " — " + subtitle
    }
    
    override func prepareForReuse() {
        colorDisposable?.dispose()
        colorDisposable = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bg = UIView()
        bg.backgroundColor = color.lighterShade()
        selectedBackgroundView = bg
    }

    // MARK: Color
    
    func observe(color: MutableProperty<UIColor>) {
        let disposeColor = color
            .producer
            .observeOn(UIScheduler())
            .startWithNext { [unowned self] color in
            self.color = color
        }
        
        colorDisposable = ScopedDisposable(disposeColor)
    }
    
    private var colorDisposable: Disposable? = nil
    
    private var color: UIColor = .prettyGray() {
        didSet {
            selectedBackgroundView?.backgroundColor = color.lighterShade()
            tintColor = color
        }
    }
}