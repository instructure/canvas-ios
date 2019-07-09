//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

import CoreData


import Marshal
import ReactiveSwift

extension FileNode {
    public static func contextIDPredicate(_ contextID: ContextID) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "rawContextID", contextID.canvasContextID)
    }
    
    @objc public static func hiddenForUserPredicate(_ hiddenForUser: Bool) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "hiddenForUser", hiddenForUser as CVarArg)
    }
    
    @objc public static func folderIDPredicate(_ folderID: String?) -> NSPredicate {
        if let folderID = folderID {
            return NSPredicate(format:"%K == %@", "parentFolderID", folderID)
        } else {
            return rootFolderPredicate(true)
        }
    }

    @objc public static func rootFolderPredicate(_ isInRootFolder: Bool) -> NSPredicate {
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
    @objc var didDeleteItemAtIndexPath: ((IndexPath)->Void)? = nil
    
    override init(collection: FetchedCollection<FileNode>, viewModelFactory: @escaping (FileNode) -> VM) {
        super.init(collection: collection, viewModelFactory: viewModelFactory)
    }
    
    @objc open func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return (collection[indexPath].contextID.context == .user)
   }
    
    @objc open func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            didDeleteItemAtIndexPath?(indexPath)
        }
    }
}
