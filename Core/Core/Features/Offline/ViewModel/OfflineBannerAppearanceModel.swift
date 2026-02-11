//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

class OfflineBannerAppearanceModel {
    enum ViewChangeRequirement { case layout, additionalInsets }

    private var contentHeight: CGFloat
    private var containerBounds: CGRect

    init(contentHeight: CGFloat, containerBounds: CGRect) {
        self.contentHeight = contentHeight
        self.containerBounds = containerBounds
    }

    func offlineContentOpacityWhen(offline: Bool) -> CGFloat {
        return offline ? 1 : 0
    }

    func onlineContentOpacityWhen(offline: Bool) -> CGFloat {
        return offline ? 0 : 1
    }

    func viewOpacityWhen(visible: Bool) -> CGFloat {
        return visible ? 1 : 0
    }

    func viewChangeRequiredUpdating(contentHeight: CGFloat, containerBounds: CGRect?) -> ViewChangeRequirement? {
        var changeRequirement: ViewChangeRequirement?

        // Covers the use case where app is background then put back to foreground
        if self.contentHeight != contentHeight {
            self.contentHeight = contentHeight
            changeRequirement = .additionalInsets
        }

        // Covers the use case of window re-size on iPadOS 26
        if let viewBounds = containerBounds, self.containerBounds != viewBounds {
            self.containerBounds = viewBounds
            changeRequirement = .layout
        }

        return changeRequirement
    }

    func containerAdditionalInsets(on isVisible: Bool) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: isVisible ? contentHeight : 0,
            right: 0
        )
    }
}
