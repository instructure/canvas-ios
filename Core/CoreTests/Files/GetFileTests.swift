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

class GetFileTest: CoreTestCase {
    let context = Context(.course, id: "1")

    func testProperties() {
        XCTAssertEqual(GetFile(context: context, fileID: "72").cacheKey, "get-file-72")
        XCTAssertEqual(GetFile(context: context, fileID: "5").scope, Scope.where(#keyPath(File.id), equals: "5"))
        XCTAssertEqual(GetFile(context: context, fileID: "1").request.context?.canvasContextID, context.canvasContextID)
    }
}
