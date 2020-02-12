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

public class CircleRefreshControl: UIRefreshControl {
    let progressView = CircleProgressView()
    var offsetObservation: NSKeyValueObservation?
    var isCompleted = false

    public var color: UIColor {
        get { progressView.color }
        set { progressView.color = newValue }
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        for v in subviews { v.removeFromSuperview() }
        layer.zPosition = -1
        addSubview(progressView)
        progressView.pin(inside: self, top: 12, bottom: 16)
        progressView.alpha = 0
        progressView.progress = 0
        offsetObservation = (superview as? UIScrollView)?.observe(\.contentOffset, options: .new) { [weak self] scrollView, _ in
            self?.updateProgress(scrollView)
        }
        addTarget(self, action: #selector(triggered), for: .primaryActionTriggered)
    }

    func updateProgress(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        progressView.transform = CGAffineTransform(translationX: 0, y: (-y / 2) - 28)
        guard !isRefreshing && (!isCompleted || y == 0) else { return }
        isCompleted = false
        let progress = min(1, max(0, -y) / (scrollView.frame.height / 5))
        progressView.alpha = min(1, progress * 2)
        progressView.progress = progress
    }

    @objc func triggered() {
        isCompleted = true
        progressView.alpha = 1
        progressView.progress = nil
    }

    public override func endRefreshing() {
        super.endRefreshing()
        UIView.animate(withDuration: 0.3, animations: { self.progressView.alpha = 0 })
    }
}
