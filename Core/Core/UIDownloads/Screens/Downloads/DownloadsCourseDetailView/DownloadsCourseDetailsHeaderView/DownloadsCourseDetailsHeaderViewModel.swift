//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class DownloadsCourseDetailsHeaderViewModel: ObservableObject {

    @Published public private(set) var hideColorOverlay: Bool = false
    @Published public private(set) var verticalOffset: CGFloat = 0
    @Published public private(set) var imageOpacity: CGFloat = 0.4
    @Published public private(set) var titleOpacity: CGFloat = 1
    @Published public private(set) var courseName = ""
    @Published public private(set) var courseColor: UIColor = .clear
    @Published public private(set) var termName = ""
    @Published public private(set) var imageURL: URL?

    public let height: CGFloat = 235

    init(courseViewModel: DownloadCourseViewModel) {
        courseName = courseViewModel.name
        imageURL = courseViewModel.imageURL
        termName = courseViewModel.termName
        courseColor = courseViewModel.color
    }

    public func scrollPositionChanged(_ bounds: ViewBoundsKey.Value) {
        guard let frame = bounds.first?.bounds else { return }
        scrollPositionYChanged(to: frame.minY)
    }

    public func shouldShowHeader(for height: CGFloat) -> Bool {
        self.height < height / 2
    }

    private func scrollPositionYChanged(to value: CGFloat) {
        if value <= 0 { // scrolling down to content
            verticalOffset = min(0, value / 2)
            // Starts from 0 and reaches 1 when the image is fully pushed out of screen
            let offsetRatio = abs(verticalOffset) / (height / 2)
            imageOpacity = hideColorOverlay ? 1 : (1 - offsetRatio) * 0.4
            titleOpacity = 1 - offsetRatio
        } else { // pull to refresh gesture, we allow the image to move along with the content
            verticalOffset = value
            imageOpacity = hideColorOverlay ? 1 : 0.4
            titleOpacity = 1
        }
    }
}
