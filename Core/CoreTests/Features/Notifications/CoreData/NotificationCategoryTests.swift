//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import XCTest
@testable import Core

class NotificationCategoryTests: CoreTestCase {
    func testGetNotificationCategories() {
        let useCase = GetNotificationCategories(channelID: "1")
        XCTAssertEqual(useCase.cacheKey, "users/self/communication_channels/1/notification_preferences")
        XCTAssertEqual(useCase.scope, Scope(
            predicate: NSPredicate(format: "%K == %@", #keyPath(NotificationCategory.channelID), "1"),
            order: [NSSortDescriptor(key: #keyPath(NotificationCategory.category), ascending: true)]
        ))
        XCTAssertEqual(useCase.request.channelID, "1")

        useCase.write(response: nil, urlResponse: nil, to: databaseClient)
        XCTAssertEqual((databaseClient.fetch() as [NotificationCategory]).count, 0)

        useCase.write(response: .init(notification_preferences: [
            .make(notification: "not3", category: "cat2", frequency: .weekly),
            .make(notification: "not1", category: "cat1", frequency: .daily),
            .make(notification: "not2", category: "cat1", frequency: .never)
        ]), urlResponse: nil, to: databaseClient)

        let models: [NotificationCategory] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(models.count, 2)
        XCTAssertEqual(models[0].category, "cat1")
        XCTAssertEqual(models[0].notifications, [ "not1", "not2" ])
        XCTAssertEqual(models[0].frequency, .daily)
        XCTAssertEqual(models[1].category, "cat2")
        XCTAssertEqual(models[1].notifications, [ "not3" ])
        XCTAssertEqual(models[1].frequency, .weekly)
    }

    func testPutNotificationCategory() {
        let useCase = PutNotificationCategory(channelID: "2", category: "cate", notifications: [ "a", "b" ], frequency: .never)
        XCTAssertNil(useCase.cacheKey)
        XCTAssertEqual(useCase.request.channelID, "2")

        useCase.write(response: nil, urlResponse: nil, to: databaseClient)
        XCTAssertEqual((databaseClient.fetch() as [NotificationCategory]).count, 0)

        // response is largely ignored
        useCase.write(response: .init(notification_preferences: [
            .make(notification: "z", category: "i", frequency: .weekly),
            .make(notification: "y", category: "j", frequency: .daily)
        ]), urlResponse: nil, to: databaseClient)

        let models: [NotificationCategory] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models[0].category, "cate")
        XCTAssertEqual(models[0].notifications, [ "a", "b" ])
        XCTAssertEqual(models[0].frequency, .never)

        let model = models[0]
        model.frequencyRaw = "bogus"
        XCTAssertEqual(model.frequency, .never)
    }
}
