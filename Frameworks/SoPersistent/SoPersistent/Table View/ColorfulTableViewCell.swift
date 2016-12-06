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
    
    

import Foundation
import ReactiveCocoa
import Result
import SoLazy
import SoPretty

public struct ColorfulViewModel: TableViewCellViewModel {
    public let color = MutableProperty(UIColor.prettyGray())
    public let title = MutableProperty("")
    public let titleFontStyle = MutableProperty(FontStyle.regular)
    public let titleTextColor = MutableProperty(UIColor.blackColor())
    public let detail = MutableProperty("")
    public let icon = MutableProperty<UIImage?>(nil)
    public let accessoryView = MutableProperty<UIView?>(nil)
    public let accessoryType = MutableProperty<UITableViewCellAccessoryType>(.None)
    public let tokenViewText = MutableProperty("")
    public let indentationLevel = MutableProperty(0)
    public let selectionEnabled = MutableProperty(true)
    public let setSelected = MutableProperty<Bool?>(nil)
    public let accessibilityIdentifier = MutableProperty<String?>(nil)
    public let accessibilityLabel = MutableProperty<String?>(nil)
    public var titleLineBreakMode = NSLineBreakMode.ByTruncatingTail

    public let style: ColorfulTableViewCell.Style

    public enum FontStyle {
        case regular
        case bold
        case italic
    }
    
    public init(style: ColorfulTableViewCell.Style) {
        self.style = style
    }
    
    public func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(style.rawValue) as? ColorfulTableViewCell else { ❨╯°□°❩╯⌢"be sure and call prepareTableView:" }
        cell.viewModel = self

        let indexPathIdentifier = "\(indexPath.section)_\(indexPath.row)"
        cell.disposable += cell.rac_a11yIdentifier <~ accessibilityIdentifier.producer.ignoreNil().map { "\($0)_cell_\(indexPathIdentifier)" }
        cell.disposable += cell.rac_a11yLabel <~ accessibilityLabel
        cell.disposable += ((cell.tokenCellTitleLabel ?? cell.textLabel)?.rac_a11yIdentifier).map { $0 <~ accessibilityIdentifier.producer.ignoreNil().map { "\($0)_title_\(indexPathIdentifier)" } }
        cell.disposable += (cell.detailTextLabel?.rac_a11yIdentifier).map { $0 <~ accessibilityIdentifier.producer.ignoreNil().map { "\($0)_detail_\(indexPathIdentifier)" } }
        cell.disposable += (cell.accessoryView?.rac_a11yIdentifier).map { $0 <~ accessibilityIdentifier.producer.ignoreNil().map { "\($0)_accessory_image_\(indexPathIdentifier)" } }
        cell.disposable += (cell.imageView?.rac_a11yIdentifier).map { $0 <~ accessibilityIdentifier.producer.ignoreNil().map { "\($0)_icon_\(indexPathIdentifier)" } }

        cell.disposable += setSelected.producer.startWithNext { [weak tableView] setSelected in
            if let selected = setSelected where selected {
                tableView?.selectRowAtIndexPath(tableView?.indexPathForCell(cell), animated: true, scrollPosition: .None)
            }
        }

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
        disposable += (detailTextLabel?.rac_text).map { $0 <~ vm.detail.producer }
        disposable += (imageView?.rac_image).map { $0 <~ vm.icon.producer }
        disposable += vm.color.producer.startWithNext { [weak self] color in
            self?.updateColor(color)
        }
        disposable += vm.accessoryView.producer.observeOn(UIScheduler()).startWithNext { [weak self] accessory in
            self?.accessoryView = accessory
        }
        disposable += vm.accessoryType.producer.startWithNext { [weak self] accessory in
            self?.accessoryType = accessory
        }
        disposable += vm.titleFontStyle.producer.startWithNext { [weak self] style in
            var fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
            switch style {
            case .italic:
                guard let italicDescriptor = fontDescriptor.fontDescriptorWithSymbolicTraits(.TraitItalic) else { break }
                let font = UIFont(descriptor: italicDescriptor, size: 0)
                self?.textLabel?.font = font
                self?.tokenCellTitleLabel?.font = font
            case .bold:
                guard let boldDescriptor = fontDescriptor.fontDescriptorWithSymbolicTraits(.TraitBold) else { break }
                let font = UIFont(descriptor: boldDescriptor, size: 0)
                self?.textLabel?.font = font
                self?.tokenCellTitleLabel?.font = font
            default:
                let font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                self?.textLabel?.font = font
                self?.tokenCellTitleLabel?.font = font
            }
        }
        disposable += vm.indentationLevel.producer.startWithNext { [weak self] level in
            self?.indentationLevel = level
        }
        disposable += vm.selectionEnabled.producer.startWithNext { [weak self] selectionEnabled in
            self?.selectionStyle = selectionEnabled ? .Default : .None
            self?.userInteractionEnabled = selectionEnabled
        }
        disposable += vm.titleTextColor.producer.startWithNext { [weak self] textColor in
            self?.textLabel?.textColor = textColor
        }

        updateTitleConstraints()

        (tokenCellTitleLabel ?? textLabel)?.lineBreakMode = vm.titleLineBreakMode
        let numberOfLines: Int
        switch vm.titleLineBreakMode {
        case .ByWordWrapping, .ByCharWrapping:
            numberOfLines = 0
        default:
            numberOfLines = 1
        }
        (tokenCellTitleLabel ?? textLabel)?.numberOfLines = numberOfLines
    }
    
    public var viewModel: ColorfulViewModel? {
        didSet {
            beginObservingViewModel()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        // Indent the images like they should be
        if let imageView = self.imageView where indentationLevel != 0 {
            imageView.frame = CGRect(x: imageView.frame.origin.x + (CGFloat(indentationLevel) * indentationWidth), y: imageView.frame.origin.y, width: imageView.frame.size.width, height: imageView.frame.size.height)
        }

        if let title = self.textLabel, let detail = self.detailTextLabel where self.reuseIdentifier == Style.RightDetail.rawValue {
            var minX: CGFloat = CGRectGetMinX(title.frame)
            let width = (CGRectGetMinX(detail.frame) - minX) - 8.0
            var frame = title.frame
            frame.size.width = width
            title.frame = frame
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
    
    public func updateColor(color: UIColor) {
        tintColor = color
        let bg = UIView()
        bg.backgroundColor = color.lighterShade()
        self.selectedBackgroundView = bg
        
        tokenView?.backgroundColor = color
    }
}
