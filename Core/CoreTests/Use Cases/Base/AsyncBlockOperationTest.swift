//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Core

class TestError: Error {
    let label: String
    init (label: String) {
        self.label = label
    }
}

typealias ErrorHandler = (Error?) -> Void

class AsyncBlockOperationTest: CoreTestCase {
    let dispatchQueue = DispatchQueue(label: "Test Queue")

    func testItRunsTheOperation() {
        var ran = false
        let asyncOp = AsyncBlockOperation { [weak self] (completionBlock: @escaping ErrorHandler) in
            self?.dispatchQueue.async {
                ran = true
                completionBlock(nil)
            }
        }
        addOperationAndWait(asyncOp)
        XCTAssertTrue(ran)
    }

    func testItRunsAndAttachesError() {
        var ran = false
        let asyncOp = AsyncBlockOperation { [weak self] (completionBlock: @escaping ErrorHandler) in
            self?.dispatchQueue.async {
                ran = true
                completionBlock(TestError(label: "Test"))
            }
        }
        addOperationAndWait(asyncOp)
        XCTAssertTrue(ran)
        guard let attachedError = asyncOp.errors.first as? TestError else {
            XCTFail()
            return
        }
        XCTAssertEqual(attachedError.label, "Test")
    }
}
