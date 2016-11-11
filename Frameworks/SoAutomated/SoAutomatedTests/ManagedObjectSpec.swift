//
//  ManagedObjectSpec.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 11/11/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import Quick
import Nimble
import SoAutomated
import TooLegit
@testable import FileKit

class ManagedObjectSpec: QuickSpec {
    override func spec() {
        describe("factories") {
            it("should create a valid object") {
                let session = Session.user1
                let node = FileNode.factory(session)
                expect(node.isValid) == true
            }

            it("should create a valid object that is a subentity") {
                let session = Session.user1
                let subentity = File.factory(session)
                expect(subentity.entity.superentity).toNot(beNil())
                expect(subentity.isValid) == true
            }
        }
    }
}
