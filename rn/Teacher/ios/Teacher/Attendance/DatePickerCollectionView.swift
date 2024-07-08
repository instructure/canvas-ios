//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import Core

class DatePickerDateCell: UICollectionViewCell {
    let label = UILabel()
    let highlightView = UIView()

    var isToday = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundLightest
        highlightView.backgroundColor = .electric
        highlightView.layer.cornerRadius = 4.0
        highlightView.clipsToBounds = true
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(highlightView)

        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        setIsHighlighted(false)

        NSLayoutConstraint.activate([
            highlightView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            highlightView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            highlightView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            highlightView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func setIsHighlighted(_ highlighted: Bool) {
        if highlighted {
            highlightView.isHidden = false
            label.textColor = .white
        } else {
            highlightView.isHidden = true
            label.textColor = isToday ? .electric : .textDarkest
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DatePickerMonthHeaderView: UICollectionReusableView {
    let stack = UIStackView()
    let yearLabel = UILabel()
    let monthLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        stack.addArrangedSubview(yearLabel)
        stack.addArrangedSubview(monthLabel)

        yearLabel.font = .scaledNamedFont(.heavy24)
        yearLabel.textColor = .textDarkest
        yearLabel.translatesAutoresizingMaskIntoConstraints = false

        monthLabel.font = .scaledNamedFont(.semibold20)
        monthLabel.textColor = .textDarkest
        monthLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 8),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
