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

import Foundation
@testable import Core
import XCTest
import CoreData

class BackgroundReadContextTests: CoreTestCase {

    func testBackgroundReadContextIsCreatedAndCached() {
        let context1 = database.backgroundReadContext
        let context2 = database.backgroundReadContext

        XCTAssertTrue(context1 === context2, "Should return same cached instance")
    }

    func testBackgroundReadContextHasCorrectConfiguration() {
        let context = database.backgroundReadContext

        XCTAssertTrue(context.automaticallyMergesChangesFromParent)
        XCTAssertEqual(context.mergePolicy as? NSMergePolicy, NSMergePolicy.mergeByPropertyObjectTrump)
    }

    func testBackgroundReadContextCanFetchData() {
        _ = Course.make(from: .make(id: "test-course"))
        try? databaseClient.save()

        let expectation = XCTestExpectation(description: "Background context can fetch data")

        database.backgroundReadContext.perform {
            let fetchRequest = NSFetchRequest<Course>(entityName: "Course")
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Course.id), "test-course")

            do {
                let results = try self.database.backgroundReadContext.fetch(fetchRequest)
                XCTAssertEqual(results.count, 1)
                XCTAssertEqual(results.first?.id, "test-course")
                expectation.fulfill()
            } catch {
                XCTFail("Fetch failed: \(error)")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testBackgroundReadContextMergesChangesFromWrites() {
        let expectation = XCTestExpectation(description: "Background context sees write changes")

        let courseID = "merge-test-course"

        database.performWriteTask { writeContext in
            _ = Course.make(from: .make(id: ID(rawValue: courseID)), in: writeContext)
            try? writeContext.save()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.database.backgroundReadContext.perform {
                let fetchRequest = NSFetchRequest<Course>(entityName: "Course")
                fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Course.id), courseID)

                do {
                    let results = try self.database.backgroundReadContext.fetch(fetchRequest)
                    XCTAssertEqual(results.count, 1, "Background context should see merged changes")
                    XCTAssertEqual(results.first?.id, courseID)
                    expectation.fulfill()
                } catch {
                    XCTFail("Fetch failed: \(error)")
                }
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testConcurrentAccessToBackgroundReadContext() {
        let expectation = XCTestExpectation(description: "Concurrent access is safe")
        expectation.expectedFulfillmentCount = 3

        for _ in 0..<3 {
            DispatchQueue.global().async {
                let context = self.database.backgroundReadContext
                context.perform {
                    let fetchRequest = NSFetchRequest<Course>(entityName: "Course")
                    _ = try? context.fetch(fetchRequest)
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testBackgroundReadContextAccessViaDatabase() {
        let context1 = database.backgroundReadContext
        let context2 = database.backgroundReadContext

        XCTAssertTrue(context1 === context2, "Should return same cached instance from database")
        XCTAssertTrue(context1.automaticallyMergesChangesFromParent)
    }
}
