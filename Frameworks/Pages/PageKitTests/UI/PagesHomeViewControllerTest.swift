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
    
    

import SoAutomated
import TooLegit
import SoPersistent
@testable import PageKit

class PagesHomeViewControllerTest: UnitTestCase {

    func testSegmentedControl_itIsAddedToTheNavBarWithTwoSegments() {
        attempt {
            let controller = try PagesHomeViewController.build()

            controller.addSegmentedControl()

            guard let control = controller.navigationItem.titleView as? UISegmentedControl else {
                XCTFail("segmented control not added to nav bar")
                return
            }
            XCTAssertEqual(control.numberOfSegments, 2)
        }
    }

    func testToggleButton_itIsAddedToTheNavBar() {
        attempt {
            let controller = try PagesHomeViewController.build()

            controller.initializeToggleButton()

            XCTAssertNotNil(controller.innerControllerToggle)
            XCTAssertNotNil(controller.navigationItem.rightBarButtonItem)
        }
    }

    func testEmbedInnerViewController_whereTheInnerControllerIsAFrontPage_embedsTheInnerController() {
        attempt {
            let controller = try PagesHomeViewController.build()

            controller.embedViewController(.frontPage)

            guard let childController = controller.childViewControllers.first as? Page.FrontPageDetailViewController else {
                XCTFail("expected FrontPageDetailViewController as child view controller")
                return
            }
            XCTAssert(controller.view.subviews.contains(childController.view))
        }
    }

    func testEmbedInnerViewController_whereTheInnerControllerIsAList_embedsTheInnerViewController() {
        attempt {
            let controller = try PagesHomeViewController.build()

            controller.embedViewController(.list)

            guard let childController = controller.childViewControllers.first as? Page.TableViewController else {
                XCTFail("expected Page.TableViewController as child view controller")
                return
            }
            XCTAssert(controller.view.subviews.contains(childController.view))
        }
    }
}
