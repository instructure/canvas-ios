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

@testable 

import XCTest

class SecretsTests: XCTestCase {
    
    func testFetch() {
        let secret = Secrets.fetch(.canvasPSPDFKit)
        XCTAssertNotNil(secret)
    }
    
    func testFeatureToggles() {
        let trueToggle = Secrets.featureEnabled(.protectedUserInformation, domain: "mobiledev.instructure.com")
        XCTAssert(trueToggle)
        
        let falseToggle = Secrets.featureEnabled(.protectedUserInformation, domain: "hogwarts.instructure.com")
        XCTAssertFalse(falseToggle)
    }
}
