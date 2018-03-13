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
    
    

import Result
import UIKit
import ReactiveSwift
import Result


import Cartography

public struct ColorfulViewModel: TableViewCellViewModel {
    public let color = MutableProperty(UIColor.prettyGray())
    public let title = MutableProperty("")
    public let titleFontStyle = MutableProperty(FontStyle.regular)
    public let titleTextColor = MutableProperty(UIColor.black)
    public let subtitle = MutableProperty("")
    public let rightDetail = MutableProperty("")
    public let icon = MutableProperty<UIImage?>(nil)
    public let accessoryView = MutableProperty<UIView?>(nil)
    public let accessoryType = MutableProperty<UITableViewCellAccessoryType>(.none)
    public let tokenViewText = MutableProperty("")
    public let indentationLevel = MutableProperty(0)
    public let selectionEnabled = MutableProperty(true)
    public let setSelected = MutableProperty<Bool?>(nil)
    public let accessibilityIdentifier = MutableProperty<String?>(nil)
    public let accessibilityLabel = MutableProperty<String?>(nil)

    public var iconSize: CGFloat = 24.0
    public var titleLineBreakMode = NSLineBreakMode.byWordWrapping
    
    public let features = MutableProperty<ColorfulTableViewCell.Features>([])

    public enum FontStyle {
        case regular
        case bold
        case italic
    }
    
    public init(features: ColorfulTableViewCell.Features = []) {
        self.features.value = features
    }
    
    public func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ColorfulTableViewCell") as? ColorfulTableViewCell else { ❨╯°□°❩╯⌢"be sure and call prepareTableView:" }
        
        cell.viewModel.value = self
        
        let indexPathIdentifier = "\(indexPath.section)_\(indexPath.row)"
        let nonNilA11yID = accessibilityIdentifier.producer.skipNil()
        
        cell.disposable += cell.rac_a11yIdentifier <~ nonNilA11yID
            .map { "\($0)_cell_\(indexPathIdentifier)" }
        
        cell.disposable += cell.titleLabel.rac_a11yIdentifier <~ nonNilA11yID
            .map { "\($0)_title_\(indexPathIdentifier)" }
        
        if let subtitle = cell.subtitleLabel {
            cell.disposable += subtitle.rac_a11yIdentifier <~ nonNilA11yID
                .map { "\($0)_subtitle_\(indexPathIdentifier)" }
        }
        
        if let accessory = cell.accessoryView {
            cell.disposable += accessory.rac_a11yIdentifier <~ nonNilA11yID
                .map { "\($0)_accessory_image_\(indexPathIdentifier)" }
        }
        
        if let icon = cell.iconView {
            cell.disposable += icon.rac_a11yIdentifier <~ nonNilA11yID
                .map { "\($0)_icon_\(indexPathIdentifier)" }
        }

        cell.disposable += setSelected.producer.startWithValues { [weak tableView, weak cell] setSelected in
            if let selected = setSelected, selected, let cell = cell {
                tableView?.selectRow(at: tableView?.indexPath(for: cell), animated: true, scrollPosition: .none)
            }
        }

        return cell
    }

    public static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.register(ColorfulTableViewCell.self, forCellReuseIdentifier: "ColorfulTableViewCell")
    }
}

public class ColorfulTableViewCell: UITableViewCell {
    let padding = CGFloat(12.0)

    public struct Features: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        public static let icon          = Features(rawValue: 1)
        public static let subtitle      = Features(rawValue: 2)
        public static let rightDetail   = Features(rawValue: 4)
        public static let token         = Features(rawValue: 8)
    }
    
    // MARK: views
    private let stack = UIStackView()
    
    public let titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont.preferredFont(forTextStyle: .body)
        title.numberOfLines = 0
        return title
    }()
    
    private(set) public weak var iconView: UIImageView?
    private(set) public weak var subtitleLabel: UILabel?
    private(set) public weak var rightDetailLabel: UILabel?
    private(set) public weak var tokenView: TokenView?

    fileprivate var disposable = CompositeDisposable()
    
    deinit {
        disposable.dispose()
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        stack.alignment = .center
        stack.axis = .horizontal
        stack.spacing = padding
        stack.isLayoutMarginsRelativeArrangement = true

        contentView.addSubview(stack)
        constrain(stack, contentView) { stack, contentView in
            stack.edges == contentView.edgesWithinMargins
        }

        imageView?.alpha = 0

        viewModel.producer
            .flatMap(.latest) { $0?.features.producer ?? .empty }
            .observe(on: UIScheduler())
            .startWithValues { [weak self] _ in
                self?.updateFeatures()
            }
    }
    
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let tokenBGColor = tokenView?.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        tokenView?.backgroundColor = tokenBGColor
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        let tokenBGColor = tokenView?.backgroundColor
        super.setSelected(selected, animated: animated)
        tokenView?.backgroundColor = tokenBGColor
    }

    private func updateFeatures() {
        // Reset
        disposable.dispose()
        disposable = CompositeDisposable()
        
        for view in Array(stack.arrangedSubviews) {
            stack.removeArrangedSubview(view)
        }
        for view in Array(stack.subviews) {
            view.removeFromSuperview()
        }
        
        guard let features = viewModel.value?.features.value else {
            return
        }
        
        let vm = viewModel.producer.skipNil()
        let tint = vm.flatMap(.latest) { $0.color.producer }
        
        disposable += self.rac_tintColor <~ tint
        disposable += titleLabel.rac_text <~ vm
            .flatMap(.latest) { $0.title.producer }
            .map { $0 == "" ? " " : $0 }
       
        disposable += vm
            .flatMap(.latest) { $0.accessoryType.producer }
            .startWithValues { [weak self] in self?.accessoryType = $0 }
        
        disposable += vm
            .flatMap(.latest) { $0.accessoryView.producer }
            .startWithValues { [weak self] in self?.accessoryView = $0 }
        
        disposable += vm
            .flatMap(.latest) { $0.titleTextColor.producer }
            .startWithValues { [weak self] in self?.titleLabel.textColor = $0 }
       
        disposable += vm
            .flatMap(.latest) { $0.titleFontStyle.producer }
            .startWithValues { [weak self] style in
                let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
                switch style {
                case .italic:
                    guard let italicDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic) else { break }
                    let font = UIFont(descriptor: italicDescriptor, size: 0)
                    self?.titleLabel.font = font
                case .bold:
                    guard let boldDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { break }
                    let font = UIFont(descriptor: boldDescriptor, size: 0)
                    self?.titleLabel.font = font
                default:
                    let font = UIFont.preferredFont(forTextStyle: .body)
                    self?.titleLabel.font = font
                }
            }
        
        disposable += vm
            .flatMap(.latest) { $0.indentationLevel.producer }
            .startWithValues { [weak self] level in
            self?.indentationLevel = level

            let indent = self?.indentationWidth ?? 10.0
            self?.stack.layoutMargins = UIEdgeInsets(top: 0, left: CGFloat(level) * indent, bottom: 0, right: 0)
        }
        
        disposable += rac_a11yLabel <~ vm
            .flatMap(.latest) { $0.accessibilityLabel.producer }
        
        disposable += vm
            .flatMap(.latest) { $0.selectionEnabled.producer }
            .startWithValues { [weak self] selectionEnabled in
                self?.selectionStyle = selectionEnabled ? .default : .none
                self?.isUserInteractionEnabled = selectionEnabled
            }

        titleLabel.lineBreakMode = viewModel.value?.titleLineBreakMode ?? .byTruncatingTail
        let numberOfLines: Int
        switch titleLabel.lineBreakMode {
        case .byWordWrapping, .byCharWrapping:
            numberOfLines = 0
        default:
            numberOfLines = 1
        }
        titleLabel.numberOfLines = numberOfLines

        
        let bg = UIView(frame: bounds)
        disposable += bg.rac_backgroundColor <~ tint.map { $0.lighterShade() }
        selectedBackgroundView = bg
        
        if features.contains(.icon) {
            let iconSize = viewModel.value?.iconSize ?? 24.0
            
            let iconView = UIImageView()
            iconView.contentMode = .center
            let widthConstraint = iconView.widthAnchor.constraint(equalToConstant: iconSize)
            widthConstraint.isActive = true
            stack.addArrangedSubview(iconView)
            self.iconView = iconView
            
            disposable += vm
                .flatMap(.latest) { $0.icon.producer }
                .startWithValues { [weak self] icon in
                    self?.iconView?.image = icon
                    self?.imageView?.image = icon
                    widthConstraint.constant = icon == nil ? 0 : iconSize
                    iconView.isHidden = icon == nil
                }
        }
        
        let vertStack = UIStackView()
        vertStack.alignment = .leading
        vertStack.axis = .vertical
        vertStack.distribution = .fill
        vertStack.spacing = 2.0
        stack.addArrangedSubview(vertStack)

        let titleContainer = UIView()
        titleContainer.addSubview(titleLabel)
        constrain(titleLabel, titleContainer) { label, container in
            label.edges == container.edges
        }
        vertStack.addArrangedSubview(titleContainer)
        
        if features.contains(.subtitle) {
            let sub = UILabel()
            sub.font = UIFont.preferredFont(forTextStyle: .caption1)
            sub.numberOfLines = 1

            let subContainer = UIView()
            subContainer.addSubview(sub)
            constrain(sub, subContainer) { label, container in
                label.edges == container.edges
            }
            vertStack.addArrangedSubview(subContainer)
            self.subtitleLabel = sub

            disposable += sub.rac_text <~ vm
                .flatMap(.latest) { $0.subtitle.producer }
                .map { $0 == "" ? " " : $0 }
            disposable += subContainer.rac_hidden <~ vm
                .flatMap(.latest) { $0.subtitle.producer }
                .map { $0.count == 0 }
        }
        
        if features.contains(.token) {
            let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 2))
            constrain(spacer) { $0.height == 2 }
            vertStack.addArrangedSubview(spacer)
            
            let token = TokenView()
            token.rac_backgroundColor <~ tint
                .map { $0 } // make it optional 😐
            disposable += token.rac_text <~ vm
                .flatMap(.latest) { $0.tokenViewText.producer }
                .map { $0 == "" ? " " : $0 }
            
            vertStack.addArrangedSubview(token)
            self.tokenView = token
        }
        
        if features.contains(.rightDetail) {
            let right = UILabel()
            right.font = titleLabel.font
            right.textColor = .prettyGray()
            right.textAlignment = .right
            stack.addArrangedSubview(right)
            self.rightDetailLabel = right
            
            disposable += right.rac_text <~ vm
                .flatMap(.latest) { $0.rightDetail.producer }
        }
    }
    
    // MARK: ViewModel
    internal let viewModel = MutableProperty<ColorfulViewModel?>(nil)
    
    // MARK: Misuse
    public required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"Sorry, no nib/storyboard support"
    }

    public override var textLabel: UILabel? {
        ❨╯°□°❩╯⌢"Don't use this, use titleLabel"
    }
    
    public override var detailTextLabel: UILabel? {
        ❨╯°□°❩╯⌢"Don't use the detail text label"
    }
}
