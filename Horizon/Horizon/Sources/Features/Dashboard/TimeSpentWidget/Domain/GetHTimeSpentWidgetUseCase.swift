//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core
import CoreData
import Foundation

final class GetHTimeSpentWidgetUseCase: APIUseCase {
    private let journey: DomainServiceProtocol
    public typealias Model = CDHTimeSpentWidgetModel
    private var subscriptions = Set<AnyCancellable>()
    public var cacheKey: String? { "get-time-spent-widget" }
    public var request: GetTimeSpentWidgetRequest { GetTimeSpentWidgetRequest() }

    init(journey: DomainServiceProtocol = DomainService(.journey)) {
        self.journey = journey
    }

    var scope: Scope { .all }

    public func write(
        response: GetTimeSpentWidgetResponse?,
        urlResponse _: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        let times = response?.data?.widgetData?.data ?? []
        var sumTimes: [String: GetTimeSpentWidgetResponse.TimeSpent] = [:]

        times.forEach { time in
            guard let courseID = time.courseID, !courseID.isEmpty else { return }

            if var existing = sumTimes[courseID] {
                let existingMinutes = existing.minutesPerDay ?? 0
                let newMinutes = time.minutesPerDay ?? 0
                existing.minutesPerDay = existingMinutes + newMinutes
                sumTimes[courseID] = existing
            } else {
                sumTimes[courseID] = time
            }
        }
        sumTimes.forEach { time in
            CDHTimeSpentWidgetModel.save(time.value, in: client)
        }
    }

    public func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping (Response?, URLResponse?, Error?) -> Void
    ) {
        journey
            .api()
            .sinkFailureOrValue(receiveFailure: { error in
                completionHandler(nil, nil, error)
            }, receiveValue: { [weak self] api in
                guard let self = self else { return }
                api.makeRequest(self.request, callback: completionHandler)
            })
            .store(in: &subscriptions)
    }
}
