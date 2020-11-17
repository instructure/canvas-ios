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
import SwiftUI

public class CircleRefreshControl: UIRefreshControl {
    var action: ((@escaping () -> Void) -> Void)?
    var offsetObservation: NSKeyValueObservation?
    let progressView = CircleProgressView()
    let snappingPoint: CGFloat = -64
    var refreshState = RefreshState.ready
    var selfAdding = false
    public override var isRefreshing: Bool { refreshState == .refreshing }

    enum RefreshState {
        case ready, refreshing, complete
    }

    public var color: UIColor? {
        get { progressView.color }
        set {
            tintColor = newValue
            progressView.color = newValue
        }
    }

    public override func didMoveToWindow() {
        if selfAdding {
            insertSelf()
        }
        super.didMoveToWindow()
    }

    public override func didMoveToSuperview() {
        // super.didMoveToSuperview() // don't allow UIRefreshControl set up
        progressView.removeFromSuperview()
        offsetObservation = nil
        guard let scrollView = superview as? UIScrollView else { return }
        scrollView.insertSubview(progressView, at: 0)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 32),
            progressView.heightAnchor.constraint(equalToConstant: 32),
            progressView.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            progressView.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor),
        ])
        progressView.alpha = 0
        progressView.layer.zPosition = -1
        progressView.progress = 0
        offsetObservation = scrollView.observe(\.contentOffset, options: .new) { [weak self] scrollView, _ in
            self?.updateProgress(scrollView)
        }
    }

    func updateProgress(_ scrollView: UIScrollView) {
        let inset = scrollView.adjustedContentInset.top
        let y = inset + scrollView.contentOffset.y
        progressView.transform = CGAffineTransform(translationX: 0, y: inset + (-y / 2) - 16)
        switch refreshState {
        case .ready:
            if scrollView.isDragging, y < snappingPoint {
                beginRefreshing()
                sendActions(for: .valueChanged)
                action?({ [weak self] in self?.endRefreshing() })
            } else {
                let progress = min(1, max(0, y / snappingPoint))
                progressView.alpha = min(1, progress * 2)
                progressView.progress = progress
            }
        case .refreshing:
            break
        case .complete:
            if y > -1 {
                refreshState = .ready
            }
        }
    }

    public override func beginRefreshing() {
        if let scrollView = superview as? UIScrollView {
            let inset = scrollView.adjustedContentInset.top
            let y = inset + scrollView.contentOffset.y
            if y > snappingPoint {
                scrollView.setContentOffset(CGPoint(x: 0, y: floor(snappingPoint - inset)), animated: true)
            }
        }
        refreshState = .refreshing
        progressView.alpha = 1
        progressView.progress = nil
    }

    public override func endRefreshing() {
        guard refreshState == .refreshing else { return }
        refreshState = .complete
        UIView.animate(withDuration: 0.3, animations: { self.progressView.alpha = 0 })
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
