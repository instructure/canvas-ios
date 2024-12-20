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

import CoreData

/**
 This usecase uploads the positions of the received dashboard cards and saves the new order received from the API to CoreData.
 */
public struct PutDashboardCardPositions: APIUseCase {
    public let cacheKey: String? = nil
    public let request: PutDashboardCardPositionsRequest

    public init(cards: [DashboardCard]) {
        let payload = cards.reduce(into: [String: Int]()) { dictionary, card in
            dictionary["course_\(card.id)"] = card.position
        }
        let body = APIDashboardCardPositions(dashboard_positions: payload)
        self.request = PutDashboardCardPositionsRequest(body: body)
    }

    public func write(response: APIDashboardCardPositions?,
                      urlResponse: URLResponse?,
                      to client: NSManagedObjectContext) {
        guard let newPositions = response?.dashboard_positions else { return }

        let receivedCardIds = Array(newPositions.keys.compactMap { Context(canvasContextID: $0)?.id })
        let predicate = NSPredicate(format: "%K in %@",
                                    #keyPath(DashboardCard.id),
                                    receivedCardIds)
        let dashboardCards: [DashboardCard] = client.fetch(scope: .init(predicate: predicate,
                                                                        order: []))
        for dashboardCard in dashboardCards {
            guard let newPosition = newPositions[dashboardCard.context.canvasContextID] else {
                continue
            }

            dashboardCard.position = newPosition
        }
    }
}
