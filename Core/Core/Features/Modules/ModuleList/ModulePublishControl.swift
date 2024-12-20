//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

final class ModulePublishControl: UIView {

    private enum Size {
        static let iconWidth: CGFloat = 24
        static let iconHeight: CGFloat = 24
        static let iconSpacing: CGFloat = 4
        static let paddingTrailing: CGFloat = 16
        static let hitAreaWidth: CGFloat = 88
        static let hitAreaMinHeight: CGFloat = 24
    }

    private var publishedView: ModuleItemPublishIndicatorView!
    private var publishButton: UIButton!
    private var clearButton: ClearButton!

    private var stackView: UIStackView!
    private var topBottomStackViewConstraints: [NSLayoutConstraint] = []
    private var centerStackViewConstraint: NSLayoutConstraint?

    private(set) var menu: UIMenu?
    private var primaryAction: (() -> Void)?
    private var isFirstUpdate = true

    var isEnabled: Bool = true {
        didSet {
            publishedView.publishedButton.isEnabled = isEnabled
            publishButton.isEnabled = isEnabled
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    init() {
        super.init(frame: .zero)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        publishedView = .init()
        publishedView.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .textDarkest
        configuration.image = .moreLine
        publishButton = .init(configuration: configuration)
        publishButton.translatesAutoresizingMaskIntoConstraints = false

        stackView = UIStackView(arrangedSubviews: [publishedView, publishButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.distribution = .equalSpacing

        NSLayoutConstraint.activate([
            publishedView.widthAnchor.constraint(equalToConstant: Size.iconWidth),
            publishButton.widthAnchor.constraint(equalToConstant: Size.iconWidth),
            publishButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])

        addSubview(stackView)
        topBottomStackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(topBottomStackViewConstraints)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Size.paddingTrailing)
        ])

        clearButton = ClearButton()
        clearButton.subButtons = [publishedView.publishedButton, publishButton]
        clearButton.setClearImage(size: CGSize(width: Size.hitAreaWidth, height: Size.hitAreaMinHeight))

        addSubview(clearButton)
        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: topAnchor),
            clearButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            clearButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            clearButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        publishedView.accessibilityElementsHidden = true
        publishButton.accessibilityElementsHidden = true
        clearButton.accessibilityElementsHidden = true
    }

    func constrainIconsCenterTo(_ guide: UIView) {
        guide.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.deactivate(topBottomStackViewConstraints)
        centerStackViewConstraint?.isActive = false

        centerStackViewConstraint = stackView.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        centerStackViewConstraint?.isActive = true
    }

    func prepareForReuse() {
        isFirstUpdate = true
        isEnabled = true
        publishedView.prepareForReuse()
        setPrimaryAction(nil)
    }

    func update(availability: FileAvailability?) {
        publishedView.update(availability: availability)
    }

    func update(isPublishInProgress: Bool) {
        let animationDuration: TimeInterval = isFirstUpdate ? 0.0 : 0.3
        isFirstUpdate = false

        publishedView.update(isPublishInProgress: isPublishInProgress, animationDuration: animationDuration)
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self else { return }
            publishButton.isEnabled = !isPublishInProgress && isEnabled
        }
    }

    func setPrimaryAction(_ action: (() -> Void)?) {
        self.menu = nil
        clearButton.menu = nil
        clearButton.showsMenuAsPrimaryAction = false
        primaryAction = action

        clearButton.removeTarget(self, action: nil, for: .primaryActionTriggered)
        if action != nil {
            clearButton.addTarget(self, action: #selector(callPrimaryAction), for: .primaryActionTriggered)
        }
    }

    func setPrimaryActionToMenu(_ menu: UIMenu) {
        self.menu = menu
        clearButton.menu = menu
        clearButton.showsMenuAsPrimaryAction = true
        primaryAction = nil

        clearButton.removeTarget(self, action: nil, for: .primaryActionTriggered)
    }

    @objc
    private func callPrimaryAction() {
        primaryAction?()
    }
}

private final class ClearButton: UIButton {

    var subButtons: [UIButton] = []

    override var isSelected: Bool {
        didSet {
            subButtons.forEach {
                $0.isHighlighted = isHighlighted
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            subButtons.forEach {
                $0.isHighlighted = isHighlighted
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    init() {
        super.init(frame: .zero)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        configuration = UIButton.Configuration.plain()
        configuration?.contentInsets.leading = 0
        configuration?.contentInsets.trailing = 0
    }

    func setClearImage(size: CGSize) {
        let image = UIGraphicsImageRenderer(size: size).image { rendererContext in
            UIColor.clear.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
        configuration?.image = image
    }
}
