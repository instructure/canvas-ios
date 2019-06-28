//
// Copyright (C) 2019-present Instructure, Inc.
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

import CoreData
@testable import Core

public class MockUploadManager: UploadManager {
    public static func reset() {
        try! UploadManager.shared.database.clearAllRecords()
    }

    public var uploadWasCalled = false
    public var addWasCalled = false
    public var cancelWasCalled = false

   public override init() {}

    open override func upload(environment: AppEnvironment = .shared, batch batchID: String, to uploadContext: FileUploadContext) {
        uploadWasCalled = true
    }

    open override func upload(environment: AppEnvironment = .shared, url: URL, batchID: String? = nil, to uploadContext: FileUploadContext) {
        uploadWasCalled = true
    }

    open override func upload(environment: AppEnvironment = .shared, file: File, to uploadContext: FileUploadContext) {
        uploadWasCalled = true
    }

    open override func cancel(environment: AppEnvironment = .shared, batchID: String) {
        cancelWasCalled = true
    }
}
