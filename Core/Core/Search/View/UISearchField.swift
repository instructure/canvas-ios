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

import Foundation

class UISearchField: UIView {
    let field = CoreTextField()

    private lazy var container: CapsuleView = {
        let container = CapsuleView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.backgroundLightest

        let icon = UIImageView(image: UIImage.smartSearchSmallLine)
        icon.tintColor = .secondaryLabel
        icon.contentMode = .center
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)

        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .always
        field.font = .scaledNamedFont(.regular14)
        field.returnKeyType = .search
        field.tintColor = .systemBlue // caret color
        field.textColor = UIColor.textDarkest

        let stack = UIStackView(arrangedSubviews: [icon, field])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 10

        container.addSubview(stack)
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.16
        container.layer.shadowRadius = 2
        container.layer.shadowOffset = CGSize(width: 0, height: 2)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 7.5),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -7.5)
        ])

        return container
    }()

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview != superview {
            container.removeFromSuperview()
        }

        guard newSuperview != nil else { return }

        addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor)
                .with { $0.priority = .defaultHigh },
            container.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            container.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }
}

class CoreTextField: UITextField {

    var clearButtonColor: UIColor = .secondaryLabel {
        didSet {
            clearButton?.tintColor = clearButtonColor
        }
    }

    private var clearButton: UIButton?

    override func layoutSubviews() {
        super.layoutSubviews()
        tweakClearButton()
    }

    /// This is to apply tint color to the default Clear Button of UITextField by
    /// looping through subviews as UITextField doesn't have a property to customize that.
    private func tweakClearButton() {
        guard clearButton == nil else { return }

        for view in subviews {
            if let button = view as? UIButton {
                button.setImage(
                    button
                        .image(for: .normal)?
                        .withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
                clearButton = button
                clearButton?.tintColor = clearButtonColor
            }
        }
    }
}

private class CapsuleView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.height, frame.width) * 0.5
    }
}
