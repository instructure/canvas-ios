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
    
    

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy
import Marshal
import ReactiveCocoa

extension FileNode {
    public static func contextIDPredicate(contextID: ContextID) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "rawContextID", contextID.canvasContextID)
    }
    
    public static func hiddenForUserPredicate(hiddenForUser: Bool) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "hiddenForUser", hiddenForUser)
    }
    
    public static func folderIDPredicate(folderID: String?) -> NSPredicate {
        if let folderID = folderID {
            return NSPredicate(format:"%K == %@", "parentFolderID", folderID)
        } else {
            return rootFolderPredicate(true)
        }
    }

    public static func rootFolderPredicate(isInRootFolder: Bool) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "isInRootFolder", isInRootFolder)
    }
    
    public static func predicate(contextID: ContextID, hiddenForUser: Bool, folderID: String?) -> NSPredicate {
        let contextID = contextIDPredicate(contextID)
        let hidden = hiddenForUserPredicate(hiddenForUser)
        let folder = folderIDPredicate(folderID)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [contextID, hidden, folder])
    }
}

extension FileNode {
    
    public static func fetchCollection(session: Session, contextID: ContextID, hiddenForUser: Bool, folderID: String?) throws -> FetchedCollection<FileNode> {
        let context = try session.filesManagedObjectContext()
        let predicate = FileNode.predicate(contextID, hiddenForUser: hiddenForUser, folderID: folderID)
        let frc = FileNode.fetchedResults(predicate, sortDescriptors: ["name".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection<FileNode>(frc: frc)
    }
    
    public static func refresher(session: Session, contextID: ContextID, hiddenForUser: Bool, folderID: String?) throws -> Refresher {
        let predicate = FileNode.predicate(contextID, hiddenForUser: hiddenForUser, folderID: folderID)
        
        let folderIDProducer: SignalProducer<String,  NSError>
        if let folderID = folderID {
            folderIDProducer = SignalProducer(value: folderID)
        } else {
            folderIDProducer = try Folder.getRootFolder(session, contextID: contextID)
                .flatMap(.Concat) { json in
                    attemptProducer {
                        let id: String = try json.stringID("id")
                        return id
                    }
            }
        }
        
        let folders = folderIDProducer.flatMap(.Concat) { folderID in
            attemptProducer {
                return try Folder.getFolders(session, folderID: folderID)
            }.flatten(.Merge)
        }
        
        let context = try session.filesManagedObjectContext()
        let foldersSync = Folder.syncSignalProducer(predicate, inContext: context, fetchRemote: folders) { folder,_ in
            folder.contextID = contextID
            folder.isInRootFolder = folderID == nil
        }
        .map { _ in () }
        
        let files = folderIDProducer.flatMap(.Concat) { folderID in
            attemptProducer {
                return try File.getFiles(session, folderID: folderID)
            }.flatten(.Merge)
        }
        
        let filesSync = File.syncSignalProducer(predicate, inContext: context, fetchRemote: files) { file,_ in
            file.contextID = contextID
            file.isInRootFolder = folderID == nil
            if let folderID = folderID {
                file.parentFolderID = folderID
            }
        }
        .map { _ in () }
        let sync = foldersSync.concat(filesSync)
        let key = File.collectionCacheKey(context, contextID: contextID, folderID: folderID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
    
    public static func getRootFolderID(session: Session, contextID: ContextID) -> SignalProducer<String,  NSError>? {
        let folderIDProducer: SignalProducer<String,  NSError>
        do {
            folderIDProducer = try Folder.getRootFolder(session, contextID: contextID)
                .flatMap(.Concat) { json in
                    attemptProducer {
                        let id: String = try json.stringID("id")
                        return id
                    }
            }
            return folderIDProducer
        } catch {
            print(error)
        }
        return nil
    }
    
    public class TableViewController: SoPersistent.TableViewController {
        private (set) public var collection: FetchedCollection<FileNode>!
        
        public func prepare<VM: TableViewCellViewModel>(collection: FetchedCollection<FileNode>, refresher: Refresher? = nil, viewModelFactory: FileNode->VM, didDeleteItemAtIndexPath: (NSIndexPath->Void)? = nil) {
            self.collection = collection
            self.refresher = refresher
            let dataSource = FileCollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
            dataSource.didDeleteItemAtIndexPath = didDeleteItemAtIndexPath
            self.dataSource = dataSource
        }
    }
}

public class FileCollectionTableViewDataSource<VM: TableViewCellViewModel>: CollectionTableViewDataSource<FetchedCollection<FileNode>, VM> {
    var didDeleteItemAtIndexPath: (NSIndexPath->Void)? = nil
    
    override init(collection: FetchedCollection<FileNode>, viewModelFactory: FileNode -> VM) {
        super.init(collection: collection, viewModelFactory: viewModelFactory)
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (collection[indexPath].contextID.context == .User)
   }
    
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            didDeleteItemAtIndexPath?(indexPath)
        }
    }
}
