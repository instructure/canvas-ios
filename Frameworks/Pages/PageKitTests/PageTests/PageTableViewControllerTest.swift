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
    
    

@testable import PageKit
import SoAutomated
import SoPersistent
import XCTest
import TooLegit
import DoNotShipThis

class PageTableViewControllerTest: XCTestCase {
    
    let session = Session.ivy
    var contextID: ContextID {
        return .course(withID: "24219")
    }
    
    func testTableViewControllerInitializer_itAssignsAttributes() {
        attempt {
            let controller = try Page.TableViewController.build()

            XCTAssertNotNil(controller.refresher)
            XCTAssertNotNil(controller.collection)
            XCTAssertNotNil(controller.route)
            XCTAssertNotNil(controller.dataSource)
        }
    }


}
