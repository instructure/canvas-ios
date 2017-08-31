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

class HelmTests: XCTestCase {
    
    var helm = HelmManager.shared
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        helm.rootViewController = nil
        super.tearDown()
    }
    
    func testPresentNotAnimated() {
        //  given
        let expectedModuleName = "/profile"
        let svc = exerciseSplitViewControllerForPresent(presentedModuleName: expectedModuleName, options:  ["animated":false])
        
        //  then
        XCTAssertFalse(svc.presentationAnimated)
    }
    
    func testPresentAnimated() {
        //  given
        let expectedModuleName = "/profile"
        let svc = exerciseSplitViewControllerForPresent(presentedModuleName: expectedModuleName, options:  ["animated":true])

        //  then
        XCTAssertTrue(svc.presentationAnimated)
    }
    
    func testPresentModalPresentationStyle() {
        //  given
        let expectedModuleName = "/profile"
        let style = "formsheet"
        let expectedStyle: UIModalPresentationStyle = .formSheet
        let svc = exerciseSplitViewControllerForPresent(presentedModuleName: expectedModuleName, options:  ["modalPresentationStyle":style])
        
        //  then
        XCTAssertEqual(svc.presentedTestViewController?.modalPresentationStyle, expectedStyle)
    }
    
    func testPresentModalPresentationStyleFullScreen() {
        //  given
        let expectedModuleName = "/profile"
        let expectedStyle: UIModalPresentationStyle = .fullScreen
        let svc = exerciseSplitViewControllerForPresent(presentedModuleName: expectedModuleName, options:  [:])
        
        //  then
        XCTAssertEqual(svc.presentedTestViewController?.modalPresentationStyle, expectedStyle)
    }
    
    func testPresentEmbedInNavigationController() {
        //  given
        let expectedModuleName = "/profile"
        let svc = exerciseSplitViewControllerForPresent(presentedModuleName: expectedModuleName, options:  ["embedInNavigationController": true])
        
        //  then
        XCTAssertTrue(svc.presentWasCalled)
        if let presentedNav = svc.presentedTestViewController as? UINavigationController, let expectedViewController = presentedNav.viewControllers.first as? HelmViewController {
            XCTAssertEqual(expectedViewController.moduleName, expectedModuleName)
        }
        else {
            XCTFail()
        }
    }
    
    func exerciseSplitViewControllerForPresent(presentedModuleName: String, options: [String: Any]) -> HelmSplitViewTestController {
        //  given
        let svc = setupSplitViewController(masterModuleName: "m1", detailModuleName: "d1")
        helm.rootViewController = svc
        
        //  when
        helm.present(presentedModuleName, withProps: [:], options: options) { viewController in
            viewController.screenConfigRendered = true
        }
        
        let expect = expectation(description: "timeout")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.2) { error in
        }

        return svc
    }
    
    func testPush() {
        let expectedModuleName = "/profile"
        let svc = exerciseSplitViewControllerForPush(sourceModule: "d1", destinationModule: expectedModuleName, props: [:], options: [:])
        if let expectedNav = svc.detailNavigationController as? HelmNavigationTestController {
            XCTAssertTrue(expectedNav.pushWasCalled)
            if let helmViewController = expectedNav.pushedViewController as? HelmViewController {
                XCTAssertEqual(helmViewController.moduleName, expectedModuleName)
            }
            else {
                XCTFail()
            }
        }
        else {
            XCTFail()
        }
    }
    
    func exerciseSplitViewControllerForPush(sourceModule: String, destinationModule: String, props: [String: Any], options: [String: Any]) -> HelmSplitViewTestController {
        //  given
        let svc = setupSplitViewControllerWithTestNavigationControllers(masterModuleName: "m1", detailModuleName: "d1")
        helm.rootViewController = svc
        
        //  when
        helm.pushFrom(sourceModule, destinationModule: destinationModule, withProps: props, options: options) { viewController in
            viewController.screenConfigRendered = true
        }
        
        let expect = expectation(description: "timeout")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.2) { error in
        }
        
        return svc
    }
    
    func testNavigationControllerForPushToDetailViewControllerFromDetailViewController() {
        //  given
        let svc = setupSplitViewController(masterModuleName: "m1", detailModuleName: "d1")
        XCTAssertNotNil(svc.detailNavigationController)
        //  when
        let result = helm.navigationControllerForSplitViewControllerPush(splitViewController: svc, sourceModule: "d1", destinationModule: "d2", props: [:], options: [:])
        
        //  then
        XCTAssertEqual(svc.detailNavigationController, result)
    }
    
    func testNavigationControllerForPushToMasterFromMaster() {
        //  given
        let svc = setupSplitViewController(masterModuleName: "m1", detailModuleName: "d1")
        
        //  when
        let result = helm.navigationControllerForSplitViewControllerPush(splitViewController: svc, sourceModule: "m1", destinationModule: "m2", props: [:], options: ["canBecomeMaster":true])
        
        //  then
        XCTAssertEqual(svc.masterNavigationController, result)
    }
    
    func testNavigationControllerForPushToDetailFromMaster() {
        //  given
        let svc = setupSplitViewController(masterModuleName: "m1", detailModuleName: "d1")
        let originalDetailNavController = svc.detailNavigationController
        
        //  when
        let result = helm.navigationControllerForSplitViewControllerPush(splitViewController: svc, sourceModule: "m1", destinationModule: "d2", props: [:], options: [:])
        
        //  then
        XCTAssertNotEqual(originalDetailNavController, svc.detailNavigationController)
        XCTAssertEqual(svc.detailNavigationController, result)
    }
    
    func testNavigationControllerForPushToDetailFromMasterWithEmptyDetailNav() {
        //  given
        let svc = setupSplitViewController(masterModuleName: "m1", detailModuleName: "d1")
        svc.viewControllers = [svc.viewControllers.first!]

        //  when
        let result = helm.navigationControllerForSplitViewControllerPush(splitViewController: svc, sourceModule: "m1", destinationModule: "d2", props: [:], options: [:])

        //  then
        XCTAssertNotNil(svc.detailNavigationController)
        XCTAssertEqual(svc.detailNavigationController, result)
    }
    
    func setupSplitViewController(masterModuleName: String, detailModuleName: String?) -> HelmSplitViewTestController {
        let svc = HelmSplitViewTestController()
        var viewControllers = [UIViewController]()
        let masterVC = HelmViewController(moduleName: masterModuleName, props: [:])
        let masterNav = HelmNavigationController(rootViewController: masterVC)
        viewControllers.append(masterNav)
        if let detailModuleName = detailModuleName {
            let detailVC = HelmViewController(moduleName: detailModuleName, props: [:])
            let detailNav = HelmNavigationController(rootViewController: detailVC)
            viewControllers.append(detailNav)
        }
        svc.viewControllers = viewControllers
        return svc
    }
    
    func setupSplitViewControllerWithTestNavigationControllers(masterModuleName: String, detailModuleName: String?) -> HelmSplitViewTestController {
        let svc = HelmSplitViewTestController()
        var viewControllers = [UIViewController]()
        let masterVC = HelmViewController(moduleName: masterModuleName, props: [:])
        let masterNav = HelmNavigationTestController(rootViewController: masterVC)
        viewControllers.append(masterNav)
        if let detailModuleName = detailModuleName {
            let detailVC = HelmViewController(moduleName: detailModuleName, props: [:])
            let detailNav = HelmNavigationTestController(rootViewController: detailVC)
            viewControllers.append(detailNav)
        }
        svc.viewControllers = viewControllers
        return svc
    }
}

class HelmSplitViewTestController: HelmSplitViewController {
    var presentWasCalled: Bool = false
    weak var presentedTestViewController: UIViewController?
    var presentationAnimated = false
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentWasCalled = true
        presentedTestViewController = viewControllerToPresent
        presentationAnimated = flag
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

class HelmNavigationTestController: HelmNavigationController {
    var pushWasCalled: Bool = false
    weak var pushedViewController: UIViewController?
    var pushAnimated: Bool = false
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        pushAnimated = animated
        pushWasCalled = true
        super.pushViewController(viewController, animated: animated)
    }
}
