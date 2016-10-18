//
//  FileSpec.swift
//  FileKit
//
//  Created by Egan Anderson on 5/23/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import FileKit
import SoAutomated
import TooLegit
import UIKit
import Quick
import Nimble

class FileSpec: QuickSpec {
    override func spec() {
        describe("File") {
            describe("deleteFileNode") {
                it("through a network call should delete the file") {
                    let session = User(credentials: .user4).session
                    let contextID = ContextID(id: "6782429", context: .User)
                    let file = File.build(inSession: session) {
                        $0.id = "85285506"
                        $0.contextID = contextID
                        $0.name = "file"
                    }
                    let count = File.observeCount(inSession: session)
                    expect {
                        session.playback("delete-file", in: currentBundle) {
                            waitUntil { done in
                                try! file.deleteFileNode(session, shouldForce: true).startWithCompletedAction(done)
                            }
                            try! session.filesManagedObjectContext().processPendingChanges()
                        }
                    }.to(change({ count.currentCount }, from: 1, to: 0))
                }
            }
        }
    }
}
