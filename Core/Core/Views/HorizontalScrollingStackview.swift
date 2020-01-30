//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class HorizontalScrollingStackview: UIView {

    public var scrollView: UIScrollView!
    private var stackView: UIStackView!
    public var arrangedSubviews: [UIView] {
        return stackView.arrangedSubviews
    }
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        scrollView = UIScrollView()
        stackView = {
            let s = UIStackView()
            s.axis = .horizontal
            s.distribution = .fill
            s.alignment = .fill
            s.spacing = 12
            return s
        }()

        addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalTo: widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: heightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor),
        ])
    }

    public func addArrangedSubview(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }

    public func leftAlignArrangedSubviews() {
        let leftAlignViewsSpacer = UIView()
        leftAlignViewsSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.addArrangedSubview(leftAlignViewsSpacer)
    }
}
