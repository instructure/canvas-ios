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
    var selectedSortById: Int? { get }
    func saveGrading(id: String?)
    func saveSortByOption(id: Int?)
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

    public var selectedGradingId: String? {
        appEnvironment.userDefaults?.selectedGradingPeriodIds?[courseId]
    }

    public var selectedSortById: Int? {
        appEnvironment.userDefaults?.selectedSortByOptionIds?[courseId]
    }

    public func saveGrading(id: String?) {
        let gradingId = id ?? gradingShowAllId
        if appEnvironment.userDefaults?.selectedGradingPeriodIds == nil {
            appEnvironment.userDefaults?.selectedGradingPeriodIds = [courseId: gradingId]
        } else {
            appEnvironment.userDefaults?.selectedGradingPeriodIds?[courseId] = gradingId
        }
    }

    public func saveSortByOption(id: Int?) {
        let sortById = id ?? GradeArrangementOptions.groupName.rawValue
        if appEnvironment.userDefaults?.selectedSortByOptionIds == nil {
            appEnvironment.userDefaults?.selectedSortByOptionIds = [courseId: sortById]
        } else {
            appEnvironment.userDefaults?.selectedSortByOptionIds?[courseId] = sortById
        }
    }
}
