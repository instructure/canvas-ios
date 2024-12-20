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
    @IBOutlet unowned var publishedButton: UIButton!
    @IBOutlet unowned var publishInProgressIndicator: CircleProgressView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }

    init() {
        super.init(frame: .zero)
        loadFromXib()
    }

    func prepareForReuse() {
        publishedButton.alpha = 1
        publishInProgressIndicator.alpha = 0
        publishInProgressIndicator.stopAnimating()
        isHidden = false
    }

    func update(availability: FileAvailability?) {
        setupState(with: availability)
    }

    func update(isPublishInProgress isUpdating: Bool, animationDuration: TimeInterval) {
        if isUpdating {
            publishInProgressIndicator.startAnimating()
        }

        UIView.animate(withDuration: animationDuration) { [weak publishInProgressIndicator, weak publishedButton] in
            publishInProgressIndicator?.alpha = isUpdating ? 1 : 0
            publishedButton?.alpha = isUpdating ? 0 : 1
        } completion: { [weak publishInProgressIndicator] _ in
            if !isUpdating {
                publishInProgressIndicator?.stopAnimating()
            }
        }
    }

    private func setupState(with fileAvilability: FileAvailability?) {
        guard let fileAvilability else {
            isHidden = true
            return
        }

        let image: UIImage
        let tintColor: UIColor
        switch fileAvilability {
        case .published:
            image = .publishSolid
            tintColor = UIColor.backgroundSuccess
        case .unpublished:
            image = .noSolid
            tintColor = UIColor.textDark
        case .hidden:
            image = .offLine
            tintColor = UIColor.textWarning
        case .scheduledAvailability:
            image = .calendarMonthLine
            tintColor = UIColor.textWarning
        }

        publishedButton.setImage(image, for: .normal)
        publishedButton.tintColor = tintColor
        isHidden = false
    }
}
