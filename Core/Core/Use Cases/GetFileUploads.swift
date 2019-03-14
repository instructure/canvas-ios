//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public struct GetFileUploads: UseCase {
    public typealias Model = FileUpload

    // Response doesn't matter so this is just a Codable stub
    public typealias Response = Int

    public let context: FileUploadContext

    public var cacheKey: String?

    public var scope: Scope {
        return .where(#keyPath(FileUpload.contextRaw), equals: context.rawValue)
    }

    public init(context: FileUploadContext) {
        self.context = context
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping (Response?, URLResponse?, Error?) -> Void) {
        completionHandler(1, nil, nil)
    }
    public func write(response: Int?, urlResponse: URLResponse?, to client: PersistenceClient) throws {}
}
