//
// Copyright (C) 2018-present Instructure, Inc.
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

public class GetFile: DetailUseCase<GetFileRequest, File> {
    let courseID: String
    let fileID: String

    public init(courseID: String, fileID: String, env: AppEnvironment = .shared) {
        self.courseID = courseID
        self.fileID = fileID
        let request = GetFileRequest(context: ContextModel(.course, id: courseID), fileID: fileID)
        super.init(api: env.api, database: env.database, request: request)
    }

    override var predicate: NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(File.id), fileID)
    }

    override func updateModel(_ model: File, using item: APIFile, in client: PersistenceClient) throws {
        try model.update(fromApiModel: item, in: client)
    }
}
