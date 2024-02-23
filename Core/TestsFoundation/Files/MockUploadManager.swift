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
@testable import Core

public class MockUploadManager: UploadManager {
    public static func reset() {
    }

    public var uploadWasCalled = false
    public var addWasCalled = false
    public var cancelWasCalled = false
    public var canceledBatchID: String?

   public init() {
        super.init(identifier: "mock")
    }

    public override var database: NSPersistentContainer {
        return singleSharedTestDatabase
    }

    public override func add(url: URL, batchID: String) throws -> File {
        addWasCalled = true
        return try super.add(url: url, batchID: batchID)
    }

    open override func upload(batch batchID: String, to uploadContext: FileUploadContext, callback: (() -> Void)? = nil) {
        uploadWasCalled = true
    }

    open override func upload(url: URL, batchID: String? = nil, to uploadContext: FileUploadContext, folderPath: String? = nil, callback: (() -> Void)? = nil) {
        uploadWasCalled = true
        callback?()
    }

    open override func upload(file: File, to uploadContext: FileUploadContext, folderPath: String? = nil, baseURL: URL? = nil, callback: (() -> Void)? = nil) {
        uploadWasCalled = true
        callback?()
    }

    open override func cancel(batchID: String) {
        cancelWasCalled = true
        canceledBatchID = batchID
    }

    open override func cancel(file: File) {
        cancelWasCalled = true
    }
}
