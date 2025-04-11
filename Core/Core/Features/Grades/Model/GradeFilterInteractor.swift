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

import Foundation

public protocol GradeFilterInteractor {
    var gradingShowAllId: String { get }
    var selectedGradingId: String? { get }
    var selectedSortById: String? { get }
    var isParentApp: Bool { get }
    func saveSortByOption(type: GradeArrangementOptions)
}

public final class GradeFilterInteractorLive {

    // MARK: - Properties
    private let appEnvironment: AppEnvironment
    private let courseId: String

    // MARK: - Init
    public init(
        appEnvironment: AppEnvironment,
        courseId: String
    ) {
        self.appEnvironment = appEnvironment
        self.courseId = courseId
    }
}

extension GradeFilterInteractorLive: GradeFilterInteractor {
    /// -1 is dummy id so can present `All` grading period
    public var gradingShowAllId: String {
        "-1"
    }

    public var isParentApp: Bool {
        appEnvironment.app == .parent
    }

    public var selectedGradingId: String? {
        return appEnvironment.userDefaults?.selectedGradingPeriodIdsByCourseIDs?[courseId]
    }

    public var selectedSortById: String? {
        appEnvironment.userDefaults?.selectedSortByOptionIDs?[courseId]
    }

    public func saveSortByOption(type: GradeArrangementOptions) {
        let sortById = type.rawValue
        if appEnvironment.userDefaults?.selectedSortByOptionIDs == nil {
            appEnvironment.userDefaults?.selectedSortByOptionIDs = [courseId: sortById]
        } else {
            appEnvironment.userDefaults?.selectedSortByOptionIDs?[courseId] = sortById
        }
    }
}
