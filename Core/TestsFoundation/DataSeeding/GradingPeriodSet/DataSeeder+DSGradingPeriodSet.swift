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

extension DataSeeder {
    public func createGradingPeriodSet(title: String, enrollmentTerms: [DSEnrollmentTerm]) -> DSGradingPeriodSet {
        let enrollmentTermIds = enrollmentTerms.map { $0.id }
        let requestedBody = CreateDSGradingPeriodSetRequest.Body(
            enrollment_term_ids: enrollmentTermIds,
            grading_period_set: .init(title: title)
        )
        let request = CreateDSGradingPeriodSetRequest(body: requestedBody)
        return makeRequest(request).grading_period_set
    }

    public func addGradingPeriod(
        gradingPeriodSet: DSGradingPeriodSet,
        title: String,
        startDate: Date,
        endDate: Date,
        closeDate: Date
    ) -> DSGradingPeriod {
        let requestedGradingPeriod = CreateDSGradingPeriodSetPatchRequest.RequestedDSGradingPeriod(
            title: title,
            startDate: startDate,
            endDate: endDate,
            closeDate: closeDate
        )
        let requestedBody = CreateDSGradingPeriodSetPatchRequest.Body(grading_periods: [requestedGradingPeriod])
        let request = CreateDSGradingPeriodSetPatchRequest(gradingPeriodSet: gradingPeriodSet, body: requestedBody)
        return makeRequest(request).grading_periods.last!
    }
}
