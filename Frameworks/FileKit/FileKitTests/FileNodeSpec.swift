//
//  FileNodeSpec.swift
//  FileKit
//
//  Created by Nathan Armstrong on 10/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import FileKit
import Quick
import Nimble
import SoAutomated
import TooLegit
import Result

class FileNodeSpec: QuickSpec {
    override func spec() {
        describe("FileNode") {
            describe("refresher") {
                it("creates files and folders") {
                    let session = User(credentials: .user4).session
                    let contextID = ContextID(id: "6782429", context: .User)
                    let refresher = try! FileNode.refresher(session, contextID: contextID, hiddenForUser: false, folderID: "10119415")

                    let count = File.observeCount(inSession: session)
                    expect {
                        refresher.playback("refresh-files-and-folders", in: currentBundle, with: session)
                    }.to(change({ count.currentCount }, from: 0, to: 136))
                }
            }
        }
    }
}
