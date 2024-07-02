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
    public var scrollView = UIScrollView()
    private var stackView = UIStackView()

    public var arrangedSubviews: [UIView] { stackView.arrangedSubviews }

    public private(set) lazy var leadingPadding = stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor)
    public private(set) lazy var trailingPadding = scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
    public private(set) lazy var topPadding = stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor)
    public private(set) lazy var bottomPadding = scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)

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
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: heightAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            leadingPadding, trailingPadding, topPadding, bottomPadding
        ])
    }

    public func addArrangedSubview(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
}
