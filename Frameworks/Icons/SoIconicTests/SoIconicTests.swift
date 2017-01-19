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
import SoIconic

class SoIconicTests: XCTestCase {
    
    fileprivate func imageExists(_ image: UIImage) {
        // who cares
    }
    
    func testIcons() {
        imageExists(.icon(.course))
        imageExists(.icon(.course, filled: true))
        
        imageExists(.icon(.calendar))
        imageExists(.icon(.calendar, filled: true))
        
        imageExists(.icon(.inbox))
        imageExists(.icon(.inbox, filled: true))
        
        
        imageExists(.icon(.announcement))
        
        imageExists(.icon(.edit, filled: true))
        
        imageExists(.icon(.assignment))
        
        imageExists(.icon(.quiz))
        
        imageExists(.icon(.lti))
        
        imageExists(.icon(.discussion))

        imageExists(.icon(.page))
    }
}
