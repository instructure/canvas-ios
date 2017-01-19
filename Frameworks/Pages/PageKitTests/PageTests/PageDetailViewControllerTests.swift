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
import TooLegit
import SoPersistent

class PageDetailViewControllerTests : UnitTestCase {

    func testRefresherConfiguration_itContainsOneActionForTheTarget() {
        attempt {
            let controller = try Page.DetailViewController.build()

            controller.configureRefresher()

            XCTAssertEqual(controller.refresher.refreshControl.actions(forTarget: controller, forControlEvent: .valueChanged)?.count, 1)
        }
    }

    func testRefresherConfiguration_itIsAddedToTheControllerScrollView() {
        attempt {
            let controller = try Page.DetailViewController.build()

            controller.configureRefresher()

            XCTAssert(controller.webView.scrollView.subviews.contains(controller.refresher.refreshControl))
        }
    }

    func testWebViewRouting_whenTheLinkContainsMailToPrefix_itStartsTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = URLRequest(url: URL(string: "mailto:test@example.com")!)

            XCTAssertTrue(controller.webView(controller.webView, shouldStartLoadWith: request, navigationType: .linkClicked))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_whenRegularURLAndTheLinkIsNotClicked_itStartsTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = URLRequest(url: URL(string: "https://someurl.com/")!)

            XCTAssertTrue(controller.webView(controller.webView, shouldStartLoadWith: request, navigationType: .other))
            XCTAssertFalse(routed)
        }
    }


    func testWebViewRouting_whenTheLinkIsNotClicked_itStartsTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = URLRequest(url: URL(string: "https://someurl.com/")!)

            XCTAssertTrue(controller.webView(controller.webView, shouldStartLoadWith: request, navigationType: .other))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_whenTheRequestLinksToSlideshare_itRefusesTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = URLRequest(url: URL(string: "https://slideshare.net/")!)

            XCTAssertFalse(controller.webView(controller.webView, shouldStartLoadWith: request, navigationType: .linkClicked))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_whenTheRequestLinksToExternalTools_itStartsTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = URLRequest(url: URL(string: "https://mobiledev.instructure.com/external_tools/retrieve?")!)

            XCTAssertTrue(controller.webView(controller.webView, shouldStartLoadWith: request, navigationType: .linkClicked))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_withASelfReferencingFragment_itRefusesTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = URLRequest(url: URL(string: "https://mobiledev.instructure.com/#section")!)

            XCTAssertFalse(controller.webView(controller.webView, shouldStartLoadWith: request, navigationType: .linkClicked))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_whenTheRequestLinksToSelf_itRefusesTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = URLRequest(url: URL(string: "https://mobiledev.instructure.com/courses/24601/pages/test-page#section")!)

            XCTAssertFalse(controller.webView(controller.webView, shouldStartLoadWith: request, navigationType: .linkClicked))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_whenTheRequestContainsAValidRoute_itRefusesTheLoadAndRoutes() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = URLRequest(url: URL(string: "https://mobiledev.instructure.com/courses/24601/pages/someotherpage")!)

            XCTAssertFalse(controller.webView(controller.webView, shouldStartLoadWith: request, navigationType: .linkClicked))
            XCTAssertTrue(routed)
        }
    }
}
