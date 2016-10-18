//
//  FolderTests.swift
//  FileKit
//
//  Created by Egan Anderson on 5/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import FileKit
import SoAutomated
import TooLegit
import Marshal
import Quick
import Nimble

class FolderSpec: QuickSpec {
    override func spec() {
        describe("Folder") {
            describe("deleteFileNode") {
                it("through a network call should delete the folder") {
                    let session = User(credentials: .user4).session
                    let folder = Folder.build(inSession: session) {
                        $0.id = "10396915"
                    }

                    let count = Folder.observeCount(inSession: session)
                    
                    expect {
                        session.playback("delete-folder", in: currentBundle) {
                            waitUntil { done in
                                try! folder.deleteFileNode(session, shouldForce: true).startWithCompletedAction(done)
                            }
                        }
                    }.to(change({ count.currentCount }, from: 1, to: 0))
                }
            }

            describe("newFolder") {
                it("through a network call should create a file") {
                    let session = User(credentials: .user4).session
                    let contextID = ContextID(id: "6782429", context: .User)
                    let count = Folder.observeCount(inSession: session)
                    expect {
                        session.playback("add-folder", in: currentBundle) {
                            waitUntil { done in
                                Folder.newFolder(session, contextID: contextID, folderID: "10119415", name: "Folder")
                                    .startWithCompletedAction(done)
                            }
                        }
                    }.to(change({ count.currentCount }, from: 0, to: 1))
                    let folder: Folder? = try! session.managedObjectContext(Folder.self).findOne(withValue: "10423645", forKey: "id")
                    expect(folder).toNot(beNil())
                    expect(folder?.contextID) == contextID
                    expect(folder?.name) == "Folder 7"
                }
            }

            describe("updateValues") {
                var session: Session!
                var folder: Folder!
                beforeEach {
                    session = .user1
                    folder = Folder(inContext: session.managedObjectContext(Folder.self))
                }
                
                it("sets hidden_for_user to false by default") {
                    var json = folderJSON
                    json.removeValueForKey("hidden_for_user")
                    try! folder.updateValues(json, inContext: folder.managedObjectContext!)
                    expect(folder.hiddenForUser) == false
                }

                it("sets the parent folder id if present") {
                    var json = folderJSON
                    json.removeValueForKey("parent_folder_id")
                    try! folder.updateValues(json, inContext: folder.managedObjectContext!)
                    expect(folder.parentFolderID).to(beNil())

                    json["parent_folder_id"] = 1
                    try! folder.updateValues(json, inContext: folder.managedObjectContext!)
                    expect(folder.parentFolderID) == "1"
                }
            }
        }
    }
}
