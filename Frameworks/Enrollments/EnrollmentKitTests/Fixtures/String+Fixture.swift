//
//  String+Fixture.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import SoAutomated

extension String: Fixture {
    public var name: String { return self }
    public var bundle: NSBundle { return NSBundle(forClass: CourseDetailsTests.self) }
}
