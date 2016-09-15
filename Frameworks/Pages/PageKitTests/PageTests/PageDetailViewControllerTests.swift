//
//  PageDetailViewControllerTests.swift
//  Pages
//
//  Created by Joseph Davison on 6/21/16.
//  Copyright © 2016 Instructure. All rights reserved.
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

            XCTAssertEqual(controller.refresher.refreshControl.actionsForTarget(controller, forControlEvent: .ValueChanged)?.count, 1)
        }
    }

    func testRefresherConfiguration_itIsAddedToTheControllerScrollView() {
        attempt {
            let controller = try Page.DetailViewController.build()

            controller.configureRefresher()

            XCTAssert(controller.webView.scrollView.subviews.contains(controller.refresher.refreshControl))
        }
    }

    func testWebViewRouting_whenNoURLIsProvided_itRefusesTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = NSURLRequest()

            XCTAssertFalse(controller.webView(controller.webView, shouldStartLoadWithRequest: request, navigationType: .LinkClicked))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_whenTheLinkContainsMailToPrefix_itStartsTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = NSURLRequest(URL: NSURL(string: "mailto:test@example.com")!)

            XCTAssertTrue(controller.webView(controller.webView, shouldStartLoadWithRequest: request, navigationType: .LinkClicked))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_whenRegularURLAndTheLinkIsNotClicked_itStartsTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = NSURLRequest(URL: NSURL(string: "https://someurl.com/")!)

            XCTAssertTrue(controller.webView(controller.webView, shouldStartLoadWithRequest: request, navigationType: .Other))
            XCTAssertFalse(routed)
        }
    }


    func testWebViewRouting_whenTheLinkIsNotClicked_itStartsTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = NSURLRequest(URL: NSURL(string: "https://someurl.com/")!)

            XCTAssertTrue(controller.webView(controller.webView, shouldStartLoadWithRequest: request, navigationType: .Other))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_whenTheRequestLinksToSlideshare_itRefusesTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = NSURLRequest(URL: NSURL(string: "https://slideshare.net/")!)

            XCTAssertFalse(controller.webView(controller.webView, shouldStartLoadWithRequest: request, navigationType: .LinkClicked))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_whenTheRequestLinksToExternalTools_itStartsTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = NSURLRequest(URL: NSURL(string: "https://mobiledev.instructure.com/external_tools/retrieve?")!)

            XCTAssertTrue(controller.webView(controller.webView, shouldStartLoadWithRequest: request, navigationType: .LinkClicked))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_withASelfReferencingFragment_itRefusesTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = NSURLRequest(URL: NSURL(string: "https://mobiledev.instructure.com/#section")!)

            XCTAssertFalse(controller.webView(controller.webView, shouldStartLoadWithRequest: request, navigationType: .LinkClicked))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_whenTheRequestLinksToSelf_itRefusesTheLoadWithoutRouting() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = NSURLRequest(URL: NSURL(string: "https://mobiledev.instructure.com/courses/24601/pages/test-page#section")!)

            XCTAssertFalse(controller.webView(controller.webView, shouldStartLoadWithRequest: request, navigationType: .LinkClicked))
            XCTAssertFalse(routed)
        }
    }

    func testWebViewRouting_whenTheRequestContainsAValidRoute_itRefusesTheLoadAndRoutes() {
        attempt {
            var routed = false
            let controller = try Page.DetailViewController.build { _,_ in routed = true }
            let request = NSURLRequest(URL: NSURL(string: "https://mobiledev.instructure.com/courses/24601/pages/someotherpage")!)

            XCTAssertFalse(controller.webView(controller.webView, shouldStartLoadWithRequest: request, navigationType: .LinkClicked))
            XCTAssertTrue(routed)
        }
    }
}