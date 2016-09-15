//
//  SoIconicTests.swift
//  SoIconicTests
//
//  Created by Derrick Hathaway on 6/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoIconic

class SoIconicTests: XCTestCase {
    
    private func imageExists(image: UIImage) {
        // who cares
    }
    
    func testIcons() {
        imageExists(.icon(.courses))
        imageExists(.icon(.courses, filled: true))
        
        imageExists(.icon(.calendar))
        imageExists(.icon(.calendar, filled: true))
        
        imageExists(.icon(.inbox))
        imageExists(.icon(.inbox, filled: true))
        
        
        imageExists(.icon(.announcements))
        
        imageExists(.icon(.edit, filled: true))
        
        imageExists(.icon(.assignment))
        
        imageExists(.icon(.quiz))
        
        imageExists(.icon(.lti))
        
        imageExists(.icon(.discussion))
    }
}
