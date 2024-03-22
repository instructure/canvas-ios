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

import Combine
import UIKit

class ModuleItemPublishIndicatorView: UIView {
    @IBOutlet private unowned var publishedIconView: PublishedIconView!
    @IBOutlet private unowned var publishInProgressIndicator: CircleProgressView!

    private var isFirstUpdate = true

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }

    func prepareForReuse() {
        publishedIconView.alpha = 1
        publishInProgressIndicator.alpha = 0
        publishInProgressIndicator.stopAnimating()
        isFirstUpdate = true
    }

    func update(availability: FileAvailability) {
        publishedIconView.setupState(with: availability)
    }

    func update(isPublishInProgress: Bool) {
        let animated = !isFirstUpdate
        isFirstUpdate = false
        updatePublishedUIState(isUpdating: isPublishInProgress, animated: animated)
    }

    private func updatePublishedUIState(isUpdating: Bool, animated: Bool) {
        if isUpdating {
            publishInProgressIndicator.startAnimating()
        }

        UIView.animate(withDuration: animated ? 0.3 : 0.0) { [weak publishInProgressIndicator, weak publishedIconView] in
            publishInProgressIndicator?.alpha = isUpdating ? 1 : 0
            publishedIconView?.alpha = isUpdating ? 0 : 1
        } completion: { [weak publishInProgressIndicator] _ in
            if !isUpdating {
                publishInProgressIndicator?.stopAnimating()
            }
        }
    }
}
