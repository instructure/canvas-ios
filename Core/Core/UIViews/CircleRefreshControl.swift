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

import SwiftUI
import UIKit

public class CircleRefreshControl: UIRefreshControl {
    var action: ((@escaping () -> Void) -> Void)?
    var offsetObservation: NSKeyValueObservation?
    let progressView = CircleProgressView()
    let snappingPoint: CGFloat = -64
    var selfAdding = false
    var isAnimating = false

    public var color: UIColor? {
        get { progressView.color }
        set { progressView.color = newValue }
    }

    override public func didMoveToWindow() {
        if selfAdding {
            insertSelf()
        }
        super.didMoveToWindow()
    }

    override public init() {
        super.init()
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(progressView)
        tintColor = .clear
        addTarget(self, action: #selector(beginRefreshing), for: .valueChanged)
    }

    override public func didMoveToSuperview() {
        offsetObservation = nil
        guard let scrollView = superview as? UIScrollView else { return }
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 32),
            progressView.heightAnchor.constraint(equalToConstant: 32),
            progressView.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            progressView.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor, constant: 16),
        ])
        progressView.isHidden = true
        offsetObservation = scrollView.observe(\.contentOffset, options: .new) { [weak self] scrollView, _ in
            self?.updateProgress(scrollView)
        }
        super.didMoveToSuperview()
    }

    func updateProgress(_ scrollView: UIScrollView) {
        guard !isAnimating else { return }
        let progress = min(abs(scrollView.contentOffset.y / snappingPoint), 1)
        if progress == 0 { progressView.isHidden = false }
        progressView.progress = progress
    }

    override public func beginRefreshing() {
        isAnimating = true
        progressView.startAnimating()
        super.beginRefreshing()
    }

    override public func endRefreshing() {
        isAnimating = false
        progressView.stopAninating()
        super.endRefreshing()
    }

    func insertSelf() {
        var parent = superview
        while parent != nil {
            if let scrollview = parent as? UIScrollView {
                selfAdding = false
                scrollview.refreshControl = self
                return
            }
            parent = parent?.superview
        }
    }
}
