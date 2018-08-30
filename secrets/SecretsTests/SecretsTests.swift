//
//  SecretsTests.swift
//  SecretsTests
//
//  Created by Matt Sessions on 8/30/18.
//  Copyright © 2018 Matt Sessions. All rights reserved.
//

import XCTest
@testable import Secrets

class SecretsTests: XCTestCase {
    
    func testSecretRetrieval() {
        let secret = Secrets.fetch(.canvasAppStore)
        XCTAssertNotNil(secret)
    }
    
    func testFeatureRetrieval() {
        let feature = Secrets.featureEnabled(.externalResources, domain: "matterhorn.stage.dcex.harvard.edu")
        XCTAssertTrue(feature)
    }
}
