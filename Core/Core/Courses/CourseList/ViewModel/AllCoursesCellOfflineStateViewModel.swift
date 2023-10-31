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

import Combine

class AllCoursesCellOfflineStateViewModel: ObservableObject {
    @Published public private(set) var isItemEnabled: Bool
    @Published public private(set) var isFavoriteStarDisabled: Bool
    public let isOfflineIndicatorVisible: Bool

    private let offlineModeInteractor: OfflineModeInteractor

    init(
        item: AllCoursesCellView.Item,
        offlineModeInteractor: OfflineModeInteractor,
        sessionDefaults: SessionDefaults
    ) {
        let isItemAvailableOffline: Bool
        switch item {
        case let .course(course):
            isItemAvailableOffline = sessionDefaults.offlineSyncSelections.contains {
                $0.contains("courses/\(course.courseId)")
            }
        case .group:
            isItemAvailableOffline = false
        }

        let calculateIsCourseEnabled: (_ isInOfflineMode: Bool) -> Bool = { isInOfflineMode in
            isInOfflineMode ? isItemAvailableOffline : true
        }
        self.isItemEnabled = calculateIsCourseEnabled(offlineModeInteractor.isOfflineModeEnabled())
        self.isOfflineIndicatorVisible = isItemAvailableOffline
        self.offlineModeInteractor = offlineModeInteractor
        self.isFavoriteStarDisabled = offlineModeInteractor.isOfflineModeEnabled()

        offlineModeInteractor
            .observeIsOfflineMode()
            .assign(to: &$isFavoriteStarDisabled)

        offlineModeInteractor
            .observeIsOfflineMode()
            .map { calculateIsCourseEnabled($0) }
            .assign(to: &$isItemEnabled)
    }
}
