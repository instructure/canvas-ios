//
//  FileNodeCollectionsTests.swift
//  FileKit
//
//  Created by Egan Anderson on 5/31/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal
import Result
@testable import FileKit

class FileNodeCollectionsTests: XCTestCase {
    func testFetchCollectionIncludesHiddenForUser() {
        attempt {
            let session = Session.nas
            let context = try session.filesManagedObjectContext()
            let contextID = ContextID(id: "6782429", context: .User)
            
            let fileHidden = File.build(context)
            fileHidden.hiddenForUser = true
            fileHidden.contextID = contextID
            fileHidden.parentFolderID = nil
            fileHidden.isInRootFolder = true
            
            let fileNotHidden = File.build(context)
            fileNotHidden.hiddenForUser = false
            fileNotHidden.contextID = contextID
            fileNotHidden.parentFolderID = nil
            fileNotHidden.isInRootFolder = true
            
            var collection = try FileNode.fetchCollection(session, contextID: contextID, hiddenForUser: false, folderID: nil)
            XCTAssert(collection.contains(fileNotHidden))
            XCTAssertFalse(collection.contains(fileHidden))
            
            collection = try FileNode.fetchCollection(session, contextID: contextID, hiddenForUser: true, folderID: nil)
            XCTAssert(collection.contains(fileHidden))
            XCTAssertFalse(collection.contains(fileNotHidden))
        }
    }
    
    func testFetchCollectionIncludesContextID() {
        attempt {
            let session = Session.nas
            let context = try session.filesManagedObjectContext()
            let contextID = ContextID(id: "6782429", context: .User)
            let wrongContextID = ContextID(id: "1", context: .User)
            
            let file = File.build(context)
            file.hiddenForUser = false
            file.contextID = contextID
            file.parentFolderID = nil
            file.isInRootFolder = true
            
            let fileWrongContextID = File.build(context)
            fileWrongContextID.hiddenForUser = false
            fileWrongContextID.contextID = wrongContextID
            fileWrongContextID.parentFolderID = nil
            fileWrongContextID.isInRootFolder = true

            let collection = try FileNode.fetchCollection(session, contextID: contextID, hiddenForUser: false, folderID: nil)
            XCTAssert(collection.contains(file))
            XCTAssertFalse(collection.contains(fileWrongContextID))
        }
    }
    
    func testFetchCollectionIncludesFolderID() {
        attempt {
            let session = Session.nas
            let context = try session.filesManagedObjectContext()
            let contextID = ContextID(id: "6782429", context: .User)
            
            let fileWithFolder = File.build(context)
            fileWithFolder.hiddenForUser = false
            fileWithFolder.contextID = contextID
            fileWithFolder.parentFolderID = "1"
            fileWithFolder.isInRootFolder = false
            
            let fileWithoutFolder = File.build(context)
            fileWithoutFolder.hiddenForUser = false
            fileWithoutFolder.contextID = contextID
            fileWithoutFolder.parentFolderID = nil
            fileWithoutFolder.isInRootFolder = true
            
            var collection = try FileNode.fetchCollection(session, contextID: contextID, hiddenForUser: false, folderID: "1")
            XCTAssert(collection.contains(fileWithFolder))
            XCTAssertFalse(collection.contains(fileWithoutFolder))
            
            collection = try FileNode.fetchCollection(session, contextID: contextID, hiddenForUser: false, folderID: nil)
            XCTAssert(collection.contains(fileWithoutFolder))
            XCTAssertFalse(collection.contains(fileWithFolder))
        }
    }
    
   func testRefresher() {
        attempt {
            let session = Session.nas
            let context = try session.filesManagedObjectContext()
            let contextID = ContextID(id: "6782429", context: .User)
            let refresher = try FileNode.refresher(session, contextID: contextID, hiddenForUser: false, folderID: "10119415")
            
            assertDifference({ File.count(inContext: context) }, 136) {
                assertDifference({ Folder.count(inContext: context) }, 7) {
                   stub(session, "refresh-files-and-folders") { expectation in
                    refresher.refreshingCompleted.observeNext(self.refreshCompletedWithExpectation(expectation))
                        refresher.refresh(true)
                    }
                }
            }
        }
    }

    func testTableViewControllerPrepare() {
        attempt {
            let session = Session.nas
            let contextID = ContextID(id: "6782429", context: .User)
            
            let collection = try FileNode.fetchCollection(session, contextID: contextID, hiddenForUser: false, folderID: nil)
            let viewModelFactory = ViewModelFactory<FileNode>.new { _ in UITableViewCell() }
            let refresher = try FileNode.refresher(session, contextID: contextID, hiddenForUser: false, folderID: nil)
            let tvc = FileNode.TableViewController()
            
            tvc.prepare(collection, refresher: refresher, viewModelFactory: viewModelFactory)
            
            XCTAssertEqual(collection, tvc.collection)
            XCTAssertNotNil(tvc.dataSource)
            XCTAssertNotNil(tvc.refresher)
        }
    }
}
