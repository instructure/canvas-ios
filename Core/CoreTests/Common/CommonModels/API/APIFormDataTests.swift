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

import Core
import XCTest

class APIFormDataTests: XCTestCase {
    let testData = "aaa".data(using: .utf8)!

    func testDataEncodeInMemory() {
        let expectedDataEncoding =
        """
        --boundary\r
        Content-Disposition: form-data; name=\"submission\"; filename=\"filename.txt\"\r
        Content-Type: text/plain\r
        \r
        aaa\r
        --boundary--\r

        """

        let testee: APIFormData = [(key: "submission", value: .data(filename: "filename.txt", type: "text/plain", data: testData))]
        let result = String(data: try! testee.encode(using: "boundary"), encoding: .utf8)
        XCTAssertEqual(result, expectedDataEncoding)
    }

    func testDataEncodeInMemoryWithQuotationInFileName() {
        let expectedDataEncoding =
        """
        --boundary\r
        Content-Disposition: form-data; name=\"submission\"; filename=\"quotation\\\".jpg\"\r
        Content-Type: text/plain\r
        \r
        aaa\r
        --boundary--\r

        """

        let testee: APIFormData = [(key: "submission", value: .data(filename: "quotation\".jpg", type: "text/plain", data: testData))]
        let result = String(data: try! testee.encode(using: "boundary"), encoding: .utf8)
        XCTAssertEqual(result, expectedDataEncoding)
    }

    func testDataEncodeToDisk() throws {
        let expectedDataEncoding =
        """
        --boundary\r
        Content-Disposition: form-data; name=\"submission\"; filename=\"filename.txt\"\r
        Content-Type: text/plain\r
        \r
        aaa\r
        --boundary--\r

        """

        let testee: APIFormData = [(key: "submission", value: .data(filename: "filename.txt", type: "text/plain", data: testData))]
        let resultURL: URL = try testee.encode(using: "boundary")

        guard let resultData = try? Data(contentsOf: resultURL) else {
            XCTFail("Failed to read result file.")
            return
        }

        let resultString = String(data: resultData, encoding: .utf8)
        XCTAssertEqual(resultString, expectedDataEncoding)
    }

    func testDataEncodeToDiskWithQuotationInFileName() throws {
        let expectedDataEncoding =
        """
        --boundary\r
        Content-Disposition: form-data; name=\"submission\"; filename=\"quotation\\\".jpg\"\r
        Content-Type: text/plain\r
        \r
        aaa\r
        --boundary--\r

        """

        let testee: APIFormData = [(key: "submission", value: .data(filename: "quotation\".jpg", type: "text/plain", data: testData))]
        let resultURL: URL = try testee.encode(using: "boundary")

        guard let resultData = try? Data(contentsOf: resultURL) else {
            XCTFail("Failed to read result file.")
            return
        }

        let resultString = String(data: resultData, encoding: .utf8)
        XCTAssertEqual(resultString, expectedDataEncoding)
    }
}
