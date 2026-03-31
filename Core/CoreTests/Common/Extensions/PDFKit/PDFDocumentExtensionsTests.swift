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

@testable import Core
import PDFKit
import XCTest

final class PDFDocumentExtensionsTests: CoreTestCase {

    private static let testData = (
        fileName1: "some file name",
        fileName2: "another name",
        pdfFileName: "file.pdf"
    )
    private lazy var testData = Self.testData

    private var testee: PDFDocument!

    override func setUp() {
        super.setUp()
        testee = createTestPDFDocument()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Write with default parameters

    func test_write_withDefaultParameters_shouldCreateFileInTemporaryDirectory() throws {
        let resultURL = try testee.write()

        XCTAssertEqual(resultURL.pathExtension, "pdf")
        XCTAssertEqual(FileManager.default.fileExists(atPath: resultURL.path), true)
        XCTAssertEqual(resultURL.path.contains("PDF_Documents"), true)
    }

    // MARK: - Write with custom directory

    func test_write_withCustomURL_shouldCreateFileInSpecifiedDirectory() throws {
        let customDirectory = URL.Directories.temporary.appendingPathComponent("CustomPDFFolder", isDirectory: true)

        let resultURL = try testee.write(to: customDirectory, name: testData.fileName1)

        XCTAssertEqual(resultURL.pathExtension, "pdf")
        XCTAssertEqual(FileManager.default.fileExists(atPath: resultURL.path), true)
        XCTAssertEqual(resultURL.path.contains("CustomPDFFolder"), true)
        XCTAssertEqual(resultURL.lastPathComponent, "\(testData.fileName1).pdf")
    }

    // MARK: - Write with custom name

    func test_write_withCustomName_shouldUseProvidedName() throws {
        let resultURL = try testee.write(name: testData.fileName1)

        XCTAssertEqual(resultURL.lastPathComponent, "\(testData.fileName1).pdf")
        XCTAssertEqual(FileManager.default.fileExists(atPath: resultURL.path), true)
    }

    func test_write_withNameIncludingPDFExtension_shouldNotDuplicateExtension() throws {
        let resultURL = try testee.write(name: testData.pdfFileName)

        XCTAssertEqual(resultURL.lastPathComponent, testData.pdfFileName)
        XCTAssertEqual(resultURL.pathExtension, "pdf")
        XCTAssertEqual(FileManager.default.fileExists(atPath: resultURL.path), true)
    }

    func test_write_withNameNotIncludingPDFExtension_shouldAppendExtension() throws {
        let resultURL = try testee.write(name: testData.fileName1)

        XCTAssertEqual(resultURL.lastPathComponent, "\(testData.fileName1).pdf")
        XCTAssertEqual(resultURL.pathExtension, "pdf")
    }

    // MARK: - Write to existing file

    func test_write_whenFileAlreadyExists_shouldReplaceFile() throws {
        let firstResultURL = try testee.write(name: testData.fileName1)
        let firstModificationDate = try FileManager.default.attributesOfItem(atPath: firstResultURL.path)[.modificationDate] as? Date

        Thread.sleep(forTimeInterval: 0.1)

        let secondResultURL = try testee.write(name: testData.fileName1)
        let secondModificationDate = try FileManager.default.attributesOfItem(atPath: secondResultURL.path)[.modificationDate] as? Date

        XCTAssertEqual(firstResultURL, secondResultURL)
        XCTAssertEqual(FileManager.default.fileExists(atPath: secondResultURL.path), true)
        if let firstDate = firstModificationDate, let secondDate = secondModificationDate {
            XCTAssertEqual(secondDate > firstDate, true)
        }
    }

    // MARK: - Write return value

    func test_write_shouldReturnURL() throws {
        let resultURL = try testee.write(name: testData.fileName1)

        XCTAssertEqual(resultURL.lastPathComponent, "\(testData.fileName1).pdf")
        XCTAssertEqual(resultURL.isFileURL, true)
    }

    // MARK: - Private helpers

    private func createTestPDFDocument() -> PDFDocument {
        let pdfData = createMinimalPDFData()
        return PDFDocument(data: pdfData)!
    }

    private func createMinimalPDFData() -> Data {
        let pdfContent = """
        %PDF-1.4
        1 0 obj
        <<
        /Type /Catalog
        /Pages 2 0 R
        >>
        endobj
        2 0 obj
        <<
        /Type /Pages
        /Kids [3 0 R]
        /Count 1
        >>
        endobj
        3 0 obj
        <<
        /Type /Page
        /Parent 2 0 R
        /MediaBox [0 0 612 792]
        /Contents 4 0 R
        /Resources <<
        /Font <<
        /F1 <<
        /Type /Font
        /Subtype /Type1
        /BaseFont /Helvetica
        >>
        >>
        >>
        >>
        endobj
        4 0 obj
        <<
        /Length 44
        >>
        stream
        BT
        /F1 12 Tf
        100 700 Td
        (Test) Tj
        ET
        endstream
        endobj
        xref
        0 5
        0000000000 65535 f
        0000000009 00000 n
        0000000058 00000 n
        0000000115 00000 n
        0000000317 00000 n
        trailer
        <<
        /Size 5
        /Root 1 0 R
        >>
        startxref
        410
        %%EOF
        """
        return pdfContent.data(using: .utf8)!
    }
}
