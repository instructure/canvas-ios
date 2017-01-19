//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import XCTest
import TooLegit
@testable import SoProgressive

class DescribeProgress: XCTestCase {

    func test_itHasSomeProperties() {
        let progress = Progress(kind: .Submitted, contextID: ContextID(id: "3232", context: .course), itemType:.assignment, itemID: "155")
        
        XCTAssertEqual(progress.contextID, ContextID(id: "3232", context: .course))
        XCTAssertEqual(progress.kind, Progress.Kind.Submitted)
        XCTAssertEqual(progress.itemID, "155")
        XCTAssertEqual(progress.itemType, Progress.ItemType.Assignment)
    }

}
