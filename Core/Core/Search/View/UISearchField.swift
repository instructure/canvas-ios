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

    override init(frame: CGRect) {
        super.init(frame: frame)

        let icon = UIImageView(image: UIImage.smartSearchSmallLine)
        icon.tintColor = .secondaryLabel
        icon.contentMode = .center
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)
        icon.translatesAutoresizingMaskIntoConstraints = false

        field.placeholder = "Search in this course"
        field.font = .scaledNamedFont(.regular14)
        field.autocapitalizationType = .none
        field.returnKeyType = .search
        field.clearButtonMode = .always
        field.tintColor = .systemBlue // caret color
        field.textColor = UIColor.textDarkest

        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.translatesAutoresizingMaskIntoConstraints = false

        let container = CapsuleView()
        container.backgroundColor = .backgroundLightest
        container.frame = CGRect(x: 0, y: 5, width: frame.width, height: frame.height - 10)
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.16
        container.layer.shadowRadius = 2
        container.layer.shadowOffset = CGSize(width: 0, height: 2)

        addSubview(container)
        container.addSubview(icon)
        container.addSubview(field)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            field.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            field.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -5),
            field.trailingAnchor
                .constraint(equalTo: container.trailingAnchor, constant: -5)
                .with { $0.priority = .defaultHigh },
            field.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { nil }
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
