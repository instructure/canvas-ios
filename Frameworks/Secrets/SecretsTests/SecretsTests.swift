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
    
    

import Quick
import Nimble
import CoreLocation

@testable import Secrets

class SecretsSpec: QuickSpec {
    override func spec() {
        describe("Secrets") {
            it("should fetch secrets") {
                let secret = Secrets.fetch(.CanvasPSPDFKit)
                expect(secret).toNot(beNil())
            }
        }
        
        describe("FeatureToggles") {
            it("should get feature toggles") {
                let trueToggle = Secrets.featureEnabled(.ProtectedUserInformation, domain: "mobiledev.instructure.com")
                expect(trueToggle).to(beTrue())
                
                let falseToggle = Secrets.featureEnabled(.ProtectedUserInformation, domain: "hogwarts.instructure.com")
                expect(falseToggle).to(beFalse())
            }
        }
    }
}
