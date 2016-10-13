//
//  ColorfulTableViewCell.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 3/15/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import SoLazy
import SoPretty

public struct ColorfulViewModel: TableViewCellViewModel {
    public let color = MutableProperty(UIColor.prettyGray())
    public let title = MutableProperty("")
    public let titleAccessibilityIdentifier = MutableProperty<String?>(nil)
    public let titleAccessibilityLabel = MutableProperty<String?>(nil)
    public let detail = MutableProperty("")
    public let detailAccessibilityIdentifier = MutableProperty<String?>(nil)
    public let icon = MutableProperty<UIImage?>(nil)
    public let accessoryView = MutableProperty<UIView?>(nil)
    public let accessoryType = MutableProperty<UITableViewCellAccessoryType>(.None)
    public let tokenViewText = MutableProperty("")
    
    public let style: ColorfulTableViewCell.Style
    
    public init(style: ColorfulTableViewCell.Style) {
        self.style = style
    }
    
    public func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(style.rawValue) as? ColorfulTableViewCell else { ❨╯°□°❩╯⌢"be sure and call prepareTableView:" }
        cell.viewModel = self
        return cell
    }
    
    public static func tableViewDidLoad(tableView: UITableView) {
        for style: ColorfulTableViewCell.Style in [.Basic, .Subtitle, .RightDetail, .Token] {
            tableView.registerNib(style.nib, forCellReuseIdentifier: style.rawValue)
        }
    }
}

public class ColorfulTableViewCell: UITableViewCell {
    public enum Style: String {
        case Basic = "ColorfulTableViewCellBasic"
        case Subtitle = "ColorfulTableViewCellSubtitle"
        case RightDetail = "ColorfulTableViewCellRightDetail"
        case Token = "ColorfulTableViewCellBasicToken"
        
        var nib: UINib {
            let bundle = NSBundle(forClass: ColorfulTableViewCell.self)
            return UINib(nibName: rawValue, bundle: bundle)
        }
    }
    
    @IBOutlet weak var tokenCellTitleLabelCenterConstraint: NSLayoutConstraint?
    @IBOutlet weak var tokenView: TokenLabelView?
    @IBOutlet weak var tokenCellTitleLabel: UILabel?
    private var disposable = CompositeDisposable()
    
    func updateTitleConstraints() {
        if tokenView?.text.value != nil && !tokenView!.text.value.isEmpty {
            tokenCellTitleLabelCenterConstraint?.constant = -8.5
        } else if tokenCellTitleLabelCenterConstraint?.constant == -8.5 {
            tokenCellTitleLabelCenterConstraint?.constant = 0
        }
    }
    
    deinit {
        disposable.dispose()
    }
    
    func beginObservingViewModel() {
        
        disposable.dispose()
        disposable = CompositeDisposable()
        
        guard let vm = viewModel else { return }
        
        disposable += (tokenView?.text).map { $0 <~ vm.tokenViewText.producer }
        disposable += ((tokenCellTitleLabel ?? textLabel)?.rac_text).map { $0 <~ vm.title.producer }
        disposable += ((tokenCellTitleLabel ?? textLabel)?.rac_a11yIdentifier).map { $0 <~ vm.titleAccessibilityIdentifier.producer }
        disposable += ((tokenCellTitleLabel ?? textLabel)?.rac_a11yLabel).map { $0 <~ vm.titleAccessibilityLabel.producer }
        disposable += (detailTextLabel?.rac_text).map { $0 <~ vm.detail.producer }
        disposable += (detailTextLabel?.rac_a11yIdentifier).map { $0 <~ vm.detailAccessibilityIdentifier.producer }
        disposable += (imageView?.rac_image).map { $0 <~ vm.icon.producer }
        disposable += vm.color.producer.startWithNext { [weak self] color in
            self?.updateColor(color)
        }
        
        disposable += vm.accessoryView.producer.startWithNext { [weak self] accessory in
            self?.accessoryView = accessory
        }
        
        disposable += vm.accessoryType.producer.startWithNext { [weak self] accessory in
            self?.accessoryType = accessory
        }
        
        updateTitleConstraints()
    }
    
    public var viewModel: ColorfulViewModel? {
        didSet {
            beginObservingViewModel()
        }
    }
    
    // Prevent token from changing background color on selection/highlight
    
    override public func setSelected(selected: Bool, animated: Bool) {
        let color = tokenView?.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if selected {
            tokenView?.backgroundColor = color
        }
    }
    
    override public func setHighlighted(highlighted: Bool, animated: Bool) {
        let color = tokenView?.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            tokenView?.backgroundColor = color
        }
    }
    
    public override func prepareForReuse() {
        viewModel = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let title = self.textLabel, let detail = self.detailTextLabel where self.reuseIdentifier == Style.RightDetail.rawValue {
            var minX: CGFloat = CGRectGetMinX(title.frame)
            let width = (CGRectGetMinX(detail.frame) - minX) - 8.0
            var frame = title.frame
            frame.size.width = width
            title.frame = frame
        }
    }
    
    public func updateColor(color: UIColor) {
        tintColor = color
        let bg = UIView()
        bg.backgroundColor = color.lighterShade()
        self.selectedBackgroundView = bg
        
        tokenView?.backgroundColor = color
    }
}
