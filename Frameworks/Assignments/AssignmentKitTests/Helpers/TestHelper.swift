//
//  TestHelper.swift
//  Assignments
//
//  Created by Nathan Armstrong on 4/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import AssignmentKit
import SoAutomated

class DummyTask: NSURLSessionTask {
    override var taskIdentifier: Int {
        get {
            return 1
        }
        set {
            // no-op
        }
    }
}

extension String: Fixture {
    public var name: String { return self }
    public var bundle: NSBundle { return NSBundle(forClass: DescribeAssignment.self) }
}

extension XCTestCase {
    var factoryImage: UIImage {
        let bundle = NSBundle(forClass: SubmissionShareTests.self)
        let path = bundle.pathForResource("hubble-large", ofType: "jpg")!
        return UIImage(contentsOfFile: path)!
    }

    var factoryURL: NSURL {
        let bundle = NSBundle(forClass: SubmissionShareTests.self)
        return bundle.URLForResource("testfile", withExtension: "txt")!
    }
}
