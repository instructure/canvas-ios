//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

@testable import Core
import XCTest

class FileUploadTargetTests: XCTestCase {

    func testCoding() {
        // MARK: - GIVEN
        let testee = FileUploadTarget(upload_url: URL(string: "/testURL")!, upload_params: ["testKey": "testValie", "nilKey": nil])
        let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: testee, requiringSecureCoding: true)

        // MARK: - WHEN
        let decodedTestee = try! NSKeyedUnarchiver.unarchivedObject(ofClass: FileUploadTarget.self, from: encodedData)

        // MARK: - THEN
        XCTAssertEqual(decodedTestee, FileUploadTarget(upload_url: URL(string: "/testURL")!, upload_params: ["testKey": "testValie", "nilKey": nil]))
    }

    func testTransformerClasses() {
        XCTAssertTrue(FileUploadTargetTransformer.allowedTopLevelClasses.contains { $0 == FileUploadTarget.self })
    }

    func testTransformerRegistration() {
        // MARK: - GIVEN
        ValueTransformer.setValueTransformer(nil, forName: FileUploadTargetTransformer.name)
        for transformerName in ValueTransformer.valueTransformerNames() {
            XCTAssertFalse(ValueTransformer(forName: transformerName) is FileUploadTargetTransformer)
        }

        // MARK: - WHEN
        FileUploadTargetTransformer.register()

        // MARK: - THEN
        let isTransformerRegistered = ValueTransformer.valueTransformerNames().contains { name in
            ValueTransformer(forName: name) is FileUploadTargetTransformer
        }
        XCTAssertTrue(isTransformerRegistered)
    }
}
