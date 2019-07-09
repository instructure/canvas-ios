//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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


final public class FileUploadBatch: NSManagedObject {
    @NSManaged public internal(set) var primitiveFileTypes: String
    @objc public internal(set) var fileTypes: [String] {
        get {
            return primitiveFileTypes.components(separatedBy: ",")
        }
        set {
            primitiveFileTypes = newValue.joined(separator: ",")
        }
    }

    @NSManaged public internal(set) var apiPath: String

    @NSManaged public internal(set) var fileUploads: Set<FileUpload>


    @objc public convenience init(session: Session, fileTypes: [String], apiPath: String) {
        let context = try! session.filesManagedObjectContext()
        self.init(inContext: context)

        self.fileTypes = fileTypes
        self.apiPath = apiPath
    }
}
