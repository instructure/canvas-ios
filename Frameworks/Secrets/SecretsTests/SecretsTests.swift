//
//  SecretsTests.swift
//  SecretsTests
//
//  Created by Layne Moseley on 10/28/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Quick
import Nimble

@testable import Secrets

class SecretsSpec: QuickSpec {
    override func spec() {
        describe("Secrets") {
            it("should fetch secrets") {
                let secret = Secrets.fetch(.CanvasPSPDFKit)
                expect(secret).toNot(beNil())
            }
        }
    }
}
