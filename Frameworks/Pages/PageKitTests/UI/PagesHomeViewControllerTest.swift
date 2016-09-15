//
//  PagesHomeViewControllerTest.swift
//  Pages
//
//  Created by Joseph Davison on 6/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
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

            controller.embedViewController(.FrontPage)

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

            controller.embedViewController(.List)

            guard let childController = controller.childViewControllers.first as? Page.TableViewController else {
                XCTFail("expected Page.TableViewController as child view controller")
                return
            }
            XCTAssert(controller.view.subviews.contains(childController.view))
        }
    }

    func testAddConstraints_addsConstraintsToTheView() {
        attempt {
            let controller = try PagesHomeViewController.build()
            let view = UIView()
            controller.view.addSubview(view)

            controller.addConstraints(view)

            XCTAssertFalse(view.translatesAutoresizingMaskIntoConstraints)
            XCTAssertEqual(controller.view.constraints.count, 4)
        }
    }



}