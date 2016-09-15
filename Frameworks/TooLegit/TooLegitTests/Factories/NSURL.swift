//
//  NSURL.swift
//  TooLegit
//
//  Created by Nathan Armstrong on 6/27/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import SoLazy

extension NSURL {
    static var image: NSURL {
        let bundle = NSBundle(forClass: SessionTests.self)
        guard let path = bundle.URLForResource("hubble-large", withExtension: "jpg") else {
            XCTFail("image not found")
            fatalError()
        }
        return path
    }
}
