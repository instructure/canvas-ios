//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import CoreData

public class GetFile: APIUseCase {
    public typealias Model = File

    let context: Context?
    let fileID: String
    let include: [GetFileRequest.Include]

    public init(context: Context?, fileID: String, include: [GetFileRequest.Include] = []) {
        self.context = context
        self.fileID = fileID
        self.include = include
    }

    public var cacheKey: String? {
        return "get-file-\(fileID)"
    }

    public var scope: Scope {
        return .where(#keyPath(File.id), equals: fileID)
    }

    public var request: GetFileRequest {
        return GetFileRequest(context: context, fileID: fileID, include: include)
    }
}

public class GetFolderFiles: CollectionUseCase {
    public typealias Model = File
    public typealias Response = Request.Response

    let context: Context

    public init(folderID: String) {
        context = Context(.folder, id: folderID)
    }

    public var cacheKey: String? {
        "\(context.pathComponent)/files"
    }

    public var request: GetFilesRequest {
        GetFilesRequest(context: context)
    }

    public var scope: Scope {
        .where(#keyPath(File.folderID), equals: context.id, orderBy: #keyPath(File.displayName), naturally: true)
    }
}

class UpdateFile: APIUseCase {
    typealias Model = File

    var cacheKey: String? { nil }
    let request: PutFileRequest
    let scope: Scope

    init(request: PutFileRequest) {
        self.request = request
        scope = .where(#keyPath(File.id), equals: request.fileID)
    }
}

class DeleteFile: DeleteUseCase {
    typealias Model = File

    var cacheKey: String? { nil }
    let request: DeleteFileRequest
    let scope: Scope

    init(fileID: String) {
        request = DeleteFileRequest(fileID: fileID)
        scope = .where(#keyPath(File.id), equals: fileID)
    }
}

class UpdateUsageRights: APIUseCase {
    typealias Model = File

    var cacheKey: String? { nil }
    let request: PutUsageRightsRequest
    let scope: Scope

    init(context: Context, fileIDs: [String], publish: Bool? = nil, usageRights: APIUsageRights) {
        request = PutUsageRightsRequest(context: context, fileIDs: fileIDs, publish: publish, usageRights: usageRights)
        scope = Scope(
            predicate: NSPredicate(format: "%K IN %@", #keyPath(File.id), fileIDs),
            order: [ NSSortDescriptor(key: #keyPath(File.id), ascending: true) ]
        )
    }

    func write(response: APIUsageRights?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        let models: [Model] = client.fetch(scope: scope)
        for model in models {
            model.usageRights = UsageRights.save(item, to: model.usageRights, in: client)
        }
    }
}
