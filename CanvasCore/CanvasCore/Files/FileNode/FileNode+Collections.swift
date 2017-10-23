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

import CoreData


import Marshal
import ReactiveSwift

extension FileNode {
    public static func contextIDPredicate(_ contextID: ContextID) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "rawContextID", contextID.canvasContextID)
    }
    
    public static func hiddenForUserPredicate(_ hiddenForUser: Bool) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "hiddenForUser", hiddenForUser as CVarArg)
    }
    
    public static func folderIDPredicate(_ folderID: String?) -> NSPredicate {
        if let folderID = folderID {
            return NSPredicate(format:"%K == %@", "parentFolderID", folderID)
        } else {
            return rootFolderPredicate(true)
        }
    }

    public static func rootFolderPredicate(_ isInRootFolder: Bool) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "isInRootFolder", isInRootFolder as CVarArg)
    }
    
    public static func predicate(_ contextID: ContextID, hiddenForUser: Bool, folderID: String?) -> NSPredicate {
        let contextID = contextIDPredicate(contextID)
        let hidden = hiddenForUserPredicate(hiddenForUser)
        let folder = folderIDPredicate(folderID)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [contextID, hidden, folder])
    }
}

extension FileNode {
    
    public static func fetchCollection(_ session: Session, contextID: ContextID, hiddenForUser: Bool, folderID: String?) throws -> FetchedCollection<FileNode> {
        let context = try session.filesManagedObjectContext()
        let predicate = FileNode.predicate(contextID, hiddenForUser: hiddenForUser, folderID: folderID)
        return try FetchedCollection<FileNode>(frc:
            context.fetchedResults(predicate, sortDescriptors: ["name".ascending])
        )
    }
    
    public static func refresher(_ session: Session, contextID: ContextID, hiddenForUser: Bool, folderID: String?) throws -> Refresher {
        let predicate = FileNode.predicate(contextID, hiddenForUser: hiddenForUser, folderID: folderID)
        
        let folderIDProducer: SignalProducer<String,  NSError>
        if let folderID = folderID {
            folderIDProducer = SignalProducer(value: folderID)
        } else {
            folderIDProducer = try Folder.getRootFolder(session, contextID: contextID)
                .flatMap(.concat) { json in
                    attemptProducer {
                        let id: String = try json.stringID("id")
                        return id
                    }
            }
        }
        
        let folders = folderIDProducer.flatMap(.concat) { folderID in
            attemptProducer {
                return try Folder.getFolders(session, folderID: folderID)
            }.flatten(.merge)
        }
        
        let context = try session.filesManagedObjectContext()
        let foldersSync = Folder.syncSignalProducer(predicate, inContext: context, fetchRemote: folders) { folder,_ in
            folder.contextID = contextID
            folder.isInRootFolder = folderID == nil
        }
        .map { _ in () }
        
        let files = folderIDProducer.flatMap(.concat) { folderID in
            attemptProducer {
                return try File.getFiles(session, folderID: folderID)
            }.flatten(.merge)
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
    
    public static func getRootFolderID(_ session: Session, contextID: ContextID) -> SignalProducer<String,  NSError>? {
        let folderIDProducer: SignalProducer<String,  NSError>
        do {
            folderIDProducer = try Folder.getRootFolder(session, contextID: contextID)
                .flatMap(.concat) { json in
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
    
    open class TableViewController: CanvasCore.TableViewController {
        fileprivate (set) open var collection: FetchedCollection<FileNode>!
        
        open func prepare<VM: TableViewCellViewModel>(_ collection: FetchedCollection<FileNode>, refresher: Refresher? = nil, viewModelFactory: @escaping (FileNode)->VM, didDeleteItemAtIndexPath: ((IndexPath)->Void)? = nil) {
            self.collection = collection
            self.refresher = refresher
            let dataSource = FileCollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
            dataSource.didDeleteItemAtIndexPath = didDeleteItemAtIndexPath
            self.dataSource = dataSource
        }
    }
}

open class FileCollectionTableViewDataSource<VM: TableViewCellViewModel>: CollectionTableViewDataSource<FetchedCollection<FileNode>, VM> {
    var didDeleteItemAtIndexPath: ((IndexPath)->Void)? = nil
    
    override init(collection: FetchedCollection<FileNode>, viewModelFactory: @escaping (FileNode) -> VM) {
        super.init(collection: collection, viewModelFactory: viewModelFactory)
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return (collection[indexPath].contextID.context == .user)
   }
    
    open func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            didDeleteItemAtIndexPath?(indexPath)
        }
    }
}
