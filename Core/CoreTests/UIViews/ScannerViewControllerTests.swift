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
import XCTest
import AVFoundation

class ScannerViewControllerTests: XCTestCase {
    lazy var controller = ScannerViewController()
    var code: String?

/*
    func testLayout() {
        controller.delegate = self
        controller.view.layoutIfNeeded()
        let object = MockAVMetadataMachineReadableCodeObject(stringValue: "abc123")
        controller.metadataOutput(
            AVCaptureMetadataOutput(),
            didOutput: [object],
            from: AVCaptureConnection(
                inputPorts: [],
                output: AVCaptureMetadataOutput()
            )
        )
        XCTAssertEqual(code, "abc123")
    }*/
}

extension ScannerViewControllerTests: ScannerDelegate {
    func scanner(_ scanner: ScannerViewController, didScanCode code: String) {
        self.code = code
    }
}
// init is unavailable, need to find another workaround
/*
class MockAVMetadataMachineReadableCodeObject: AVMetadataMachineReadableCodeObject {
    var mockStringValue: String?
    override var stringValue: String? { mockStringValue }
    init(stringValue: String) {
        self.mockStringValue = stringValue
    }
}
*/
