//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation
import CoreData

public class GetFolderByPath: CollectionUseCase {
    public typealias Model = Folder

    let context: Context
    let path: String

    var scopeContextID: String {
        if context == .currentUser, let id = AppEnvironment.shared.currentSession?.userID {
            return "user_\(id)"
        }
        return context.canvasContextID
    }

    public init(context: Context, path: String = "") {
        self.context = context
        self.path = path
    }

    public var cacheKey: String? {
        "\(context.pathComponent)/folders/by_path/\(path)"
    }

    public var request: GetContextFolderHierarchyRequest {
        GetContextFolderHierarchyRequest(context: context, fullPath: path)
    }

    public var scope: Scope { Scope(
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(Folder.canvasContextID), equals: scopeContextID),
            NSPredicate(key: #keyPath(Folder.path), equals: path),
        ]),
        orderBy: #keyPath(Folder.id)
    ) }

    public func write(response: [APIFolder]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let folder = response?.last else { return }
        FolderItem.save(folder, in: client)
    }
}

public class GetFolder: APIUseCase {
    public typealias Model = Folder

    let context: Context?
    let folderID: String

    public init(context: Context?, folderID: String) {
        self.context = context
        self.folderID = folderID
    }

    public var cacheKey: String? { "folders/\(folderID)" }

    public var request: GetFolderRequest {
        GetFolderRequest(context: context, id: folderID)
    }

    public var scope: Scope { .where(#keyPath(Folder.id), equals: folderID) }
}

public class GetFolders: CollectionUseCase {
    public typealias Model = Folder

    let context: Context

    public init(context: Context) {
        self.context = context
    }

    public var cacheKey: String? {
        "\(context.pathComponent)/folders"
    }

    public var request: GetFoldersRequest {
        GetFoldersRequest(context: context)
    }

    public var scope: Scope {
        if context.contextType == .folder {
            return .where(#keyPath(Folder.parentFolderID), equals: context.id, orderBy: #keyPath(Folder.name), naturally: true)
        }
        return .where(#keyPath(Folder.canvasContextID), equals: context.canvasContextID, orderBy: #keyPath(Folder.name), naturally: true)
    }
}

public class GetFolderItems: UseCase {
    public typealias Model = FolderItem
    public typealias Response = [APIFolderItem]

    let folderID: String

    public init(folderID: String) {
        self.folderID = folderID
    }

    public var cacheKey: String? { "/folder/\(folderID)/items" }

    public func reset(context: NSManagedObjectContext) {
        let all: [FolderItem] = context.fetch(scope: scope)
        context.delete(all)
    }

    public var scope: Scope { .where(
        #keyPath(FolderItem.parentFolderID), equals: folderID,
        orderBy: #keyPath(FolderItem.name), naturally: true
    ) }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping ([APIFolderItem]?, URLResponse?, Error?) -> Void) {
        let context = Context(.folder, id: folderID)
        var items: [APIFolderItem] = []
        var response: URLResponse?
        var error: Error?

        let group = DispatchGroup()

        group.enter()
        environment.api.exhaust(GetFilesRequest(context: context)) { files, r, e in
            files?.forEach { items.append(APIFolderItem.file($0)) }
            response = response ?? r
            error = error ?? e
            group.leave()
        }

        group.enter()
        environment.api.exhaust(GetFoldersRequest(context: context)) { folders, r, e in
            folders?.forEach { items.append(APIFolderItem.folder($0)) }
            response = response ?? r
            error = error ?? e
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            completionHandler(items, response, error)
        }
    }

    public func write(response: [APIFolderItem]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        response?.forEach({
            switch $0 {
            case .file(let file):
                FolderItem.save(file, in: client)
            case .folder(let folder):
                FolderItem.save(folder, in: client)
            }
        })
    }
}

class CreateFolder: APIUseCase {
    public typealias Model = FolderItem

    let context: Context
    let name: String
    let parentFolderID: String

    init(context: Context, name: String, parentFolderID: String) {
        self.context = context
        self.name = name
        self.parentFolderID = parentFolderID
    }

    var cacheKey: String? { nil }

    var request: PostFolderRequest {
        PostFolderRequest(context: context, name: name, parentFolderID: parentFolderID)
    }

    func write(response: APIFolder?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        FolderItem.save(item, in: client)
    }
}

class UpdateFolder: APIUseCase {
    typealias Model = Folder

    var cacheKey: String? { nil }
    let request: PutFolderRequest
    let scope: Scope

    init(folderID: String, name: String, locked: Bool, hidden: Bool, unlockAt: Date?, lockAt: Date?) {
        request = PutFolderRequest(folderID: folderID, name: name, locked: locked, hidden: hidden, unlockAt: unlockAt, lockAt: lockAt)
        scope = .where(#keyPath(Folder.id), equals: folderID)
    }
}

class DeleteFolder: DeleteUseCase {
    typealias Model = Folder

    var cacheKey: String? { nil }
    let request: DeleteFolderRequest
    let scope: Scope

    init(folderID: String, force: Bool = false) {
        request = DeleteFolderRequest(folderID: folderID, force: force)
        scope = .where(#keyPath(Folder.id), equals: folderID)
    }
}
