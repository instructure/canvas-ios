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

class GetFileTests: CoreTestCase {
    func testGetFile() {
        let context = Context(.course, id: "1")
        XCTAssertEqual(GetFile(context: context, fileID: "72").cacheKey, "get-file-72")
        XCTAssertEqual(GetFile(context: context, fileID: "5").scope, Scope.where(#keyPath(File.id), equals: "5"))
        XCTAssertEqual(GetFile(context: context, fileID: "1").request.context?.canvasContextID, context.canvasContextID)
    }

    func testGetFolderFiles() {
        let useCase = GetFolderFiles(folderID: "2")
        XCTAssertEqual(useCase.cacheKey, "folders/2/files")
        XCTAssertEqual(useCase.request.context, Context(.folder, id: "2"))
        XCTAssertEqual(useCase.scope, .where(#keyPath(File.folderID), equals: "2", orderBy: #keyPath(File.displayName), naturally: true))
    }

    func testUpdateFile() {
        let useCase = UpdateFile(request: PutFileRequest(fileID: "1", name: "f", locked: true, hidden: false, unlockAt: nil, lockAt: nil))
        XCTAssertEqual(useCase.cacheKey, nil)
        XCTAssertEqual(useCase.request.body?.locked, true)
        XCTAssertEqual(useCase.scope, .where(#keyPath(File.id), equals: "1"))
    }

    func testDeleteFile() {
        let useCase = DeleteFile(fileID: "1")
        XCTAssertEqual(useCase.cacheKey, nil)
        XCTAssertEqual(useCase.request.fileID, "1")
        XCTAssertEqual(useCase.scope, .where(#keyPath(File.id), equals: "1"))
    }

    func testUpdateUsageRights() {
        let useCase = UpdateUsageRights(context: .course("1"), fileIDs: ["1"], usageRights: .make(
            use_justification: .own_copyright
        ))
        XCTAssertEqual(useCase.cacheKey, nil)
        XCTAssertEqual(useCase.request.body?.file_ids, [ "1" ])
        XCTAssertEqual(useCase.scope, Scope(
            predicate: NSPredicate(format: "%K IN %@", #keyPath(File.id), [ "1" ]),
            order: [ NSSortDescriptor(key: #keyPath(File.id), ascending: true) ]
        ))

        File.make()
        useCase.write(response: useCase.request.body?.usage_rights, urlResponse: nil, to: databaseClient)
        let file: File? = databaseClient.fetch(scope: useCase.scope).first
        XCTAssertEqual(file?.usageRights?.useJustification, .own_copyright)
    }
}
