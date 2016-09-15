//
//  Environment.swift
//  SoLazy
//
//  Created by Nathan Armstrong on 5/3/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

public var unitTesting: Bool {
    return NSProcessInfo.processInfo().environment["XCTestConfigurationFilePath"] != nil
}
