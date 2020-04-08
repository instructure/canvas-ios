//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import TestsFoundation
import CoreData

class GetModuleItemSequenceTests: CoreTestCase {
    func testUseCase() {
        let useCase = GetModuleItemSequence(courseID: "1", assetType: .moduleItem, assetID: "2")
        XCTAssertEqual(useCase.cacheKey, "module-item-sequence/1/ModuleItem/2")
        let match = ModuleItemSequence.make(courseID: "1", assetType: .moduleItem, assetID: "2")
        let otherCourse = ModuleItemSequence.make(courseID: "2", assetType: match.assetType, assetID: match.assetID)
        let otherType = ModuleItemSequence.make(courseID: match.courseID, assetType: .file, assetID: match.assetID)
        let otherID = ModuleItemSequence.make(courseID: match.courseID, assetType: match.assetType, assetID: "44")
        XCTAssertTrue(useCase.scope.predicate.evaluate(with: match))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: otherCourse))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: otherType))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: otherID))

        useCase.write(
            response: .make(
                items: [.make(prev: .make(id: "1"), current: .make(id: "2"), next: .make(id: "3"))],
                modules: []),
            urlResponse: nil,
            to: databaseClient
        )
        XCTAssertEqual(match.prev?.id, "1")
        XCTAssertEqual(match.current?.id, "2")
        XCTAssertEqual(match.next?.id, "3")
    }
}
