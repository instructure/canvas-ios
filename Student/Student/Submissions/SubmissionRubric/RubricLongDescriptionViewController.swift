//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class RubricLongDescriptionViewController: UIViewController {

    let titleValue: String
    let longDescription: String
    weak var delegate: CoreWebViewLinkDelegate?

    private let titleGuideView = UIView()
    private var titleTop: NSLayoutConstraint?
    private var titleLeading: NSLayoutConstraint?
    private var titleTrailing: NSLayoutConstraint?
    private var titleMinimumHeight: NSLayoutConstraint?

    init(longDescription: String, title: String) {
        self.titleValue = title
        self.longDescription = longDescription
        super.init(nibName: nil, bundle: nil)

        titleGuideView.isUserInteractionEnabled = false
        titleGuideView.frame = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 0)

        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()

        navigationItem.standardAppearance = barAppearance
        navigationItem.compactAppearance = barAppearance
        navigationItem.titleView = titleGuideView

        edgesForExtendedLayout = [.top]
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let titleFrame = titleGuideView.convert(titleGuideView.bounds, to: view)
        let maxBarFittingHeight = titleFrame.origin.y * 2

        titleTop?.constant = titleFrame.minX
        titleLeading?.constant = titleFrame.minX
        titleTrailing?.constant = titleFrame.maxX - view.bounds.width
        titleMinimumHeight?.constant = maxBarFittingHeight - titleFrame.minX * 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        setupSubviews()
        addDoneButton()
    }

    private func setupSubviews() {

        // Views Creation

        let titleLabel = UILabel()
        titleLabel.text = titleValue
        titleLabel.font = UIFont.scaledNamedFont(.semibold16)
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityTraits = .header

        let webView = CoreWebView()
        webView.linkDelegate = delegate
        webView.loadHTMLString(longDescription)

        view.addSubview(titleLabel)
        view.addSubview(webView)

        // Layout

        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleTop = titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 18)
        titleLeading = titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        titleTrailing = titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        titleMinimumHeight = titleLabel
            .heightAnchor
            .constraint(greaterThanOrEqualToConstant: 44)

        NSLayoutConstraint.activate(
            [
                titleTop,
                titleLeading,
                titleTrailing,
                titleLabel
                    .heightAnchor
                    .constraint(lessThanOrEqualToConstant: view.bounds.height * 0.5),
                titleMinimumHeight
            ].compactMap { $0 }
        )

        webView.pin(inside: self.view, top: nil)

        let webViewTop = webView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10)
        webViewTop.priority = .defaultHigh

        NSLayoutConstraint.activate([
            webViewTop,
            webView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 6)
        ])
    }
}
