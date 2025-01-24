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

    public private(set) var offsetObservation: NSKeyValueObservation?
    public let progressView = CircleProgressView()
    private var selfAdding = false
    private let snappingPoint: CGFloat = 100
    public private(set) var isAnimating = false
    private var triggerStartDate: Date?

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
        tintColor = .clear
        insertSubview(progressView, at: 0)
        layer.zPosition = -1
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 32),
            progressView.heightAnchor.constraint(equalToConstant: 32),
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        progressView.alpha = 0
    }

    override public func didMoveToSuperview() {
        offsetObservation = nil
        guard let scrollView = superview as? UIScrollView else { return }
        offsetObservation = scrollView.observe(\.contentOffset, options: .new) { [weak self] scrollView, _ in
            self?.updateProgress(scrollView)
        }
        super.didMoveToSuperview()
        setNeedsLayout()
    }

    private func updateProgress(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        guard offset <= 0 else { return }
        let progress = min(abs(offset / snappingPoint), 1)

        guard !isAnimating, scrollView.isDragging else {
            if progressView.progress != nil {
                progressView.progress = progress
                progressView.alpha = progress
            }
            return
        }

        progressView.progress = progress
        progressView.alpha = progress
        if progress == 1 {
            sendActions(for: .valueChanged)
            beginRefreshing()
            triggerStartDate = Date()
        }
    }

    override public func beginRefreshing() {
        super.beginRefreshing()
        isAnimating = true
        progressView.startAnimating()
    }

    override public func endRefreshing() {
        let triggerStartDate = triggerStartDate ?? Date()
        let triggerEndDate = Date()
        let timeElapsed = triggerEndDate.timeIntervalSince1970 - triggerStartDate.timeIntervalSince1970
        let additionalDuration = 1 - timeElapsed

        DispatchQueue.main.asyncAfter(deadline: .now() + additionalDuration) {
            super.endRefreshing()
            self.progressView.alpha = 0
            self.isAnimating = false
            self.progressView.stopAnimating()
            self.triggerStartDate = nil
        }
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
