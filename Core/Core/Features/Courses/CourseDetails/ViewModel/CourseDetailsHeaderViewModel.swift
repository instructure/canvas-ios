//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Foundation
import SwiftUI

// MARK: Legacy version exists
public class CourseDetailsHeaderViewModel: ObservableObject {
    @Published public private(set) var hideColorOverlay: Bool = false
    @Published public private(set) var verticalOffset: CGFloat = 0
    @Published public private(set) var imageOpacity: CGFloat = originalImageOpacity
    @Published public private(set) var titleOpacity: CGFloat = 1
    @Published public private(set) var courseName = ""
    @Published public private(set) var courseColor: UIColor = .clear
    @Published public private(set) var termName = ""
    @Published public private(set) var imageURL: URL?

    private static let originalImageOpacity: CGFloat = 0.16

    public let courseTitleShadow = (
        color: Color(UIColor.backgroundDarkest.withAlphaComponent(0.80)),
        radius: 4 as CGFloat
    )
    public let height: CGFloat = 235

    private let env = AppEnvironment.shared
    private lazy var settings: Store<GetUserSettings> = env.subscribe(GetUserSettings(userID: "self")) { [weak self] in
        self?.hideColorOverlay = self?.settings.first?.hideDashcardColorOverlays == true
    }

    public func viewDidAppear() {
        settings.refresh()
    }

    public func courseUpdated(_ course: Course) {
        courseName = course.name ?? ""
        imageURL = course.imageDownloadURL
        termName = course.termName ?? ""
        courseColor = course.color
        imageOpacity = hideColorOverlay ? 1 : Self.originalImageOpacity
    }
}
