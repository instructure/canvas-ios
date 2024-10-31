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

import XCTest
import TestsFoundation
import CoreData
@testable import Core

final class CourseSmartSearchDescriptorTests: CoreTestCase {

    enum TestConstants {
        static let courseId: String = "demo_course_id"
        static var context: Context { Context(.course, id: courseId) }
    }

    private var interactor: CourseSmartSearchInteractor!

    override func setUp() {
        super.setUp()
        interactor = CourseSmartSearchInteractorLive()
    }

    override func tearDown() {
        interactor = nil
        super.tearDown()
    }

    func test_enablement() throws {
        // Given
        let context = Context.course("course_12345")
        let request = GetEnabledFeatureFlagsRequest(context: context)

        // When
        api.mock(request, value: [
            "smart_search",
            "dummy_flag_2"
        ])

        let descriptor = CourseSmartSearchDescriptor(
            context: context,
            interactor: interactor
        )
        drainMainQueue()

        // Then
        XCTAssertSingleOutputEquals(descriptor.isEnabled, true)

        // When
        let featureFlag: FeatureFlag? = databaseClient.first(scope: .where("name", equals: "smart_search"))
        featureFlag?.enabled = false

        databaseClient.saveIfNeeded()
        drainMainQueue()

        // Then
        XCTAssertSingleOutputEquals(descriptor.isEnabled, false)
    }
}

private extension NSManagedObjectContext {
    func saveIfNeeded() {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
