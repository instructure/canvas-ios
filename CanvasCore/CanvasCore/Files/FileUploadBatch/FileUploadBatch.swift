//
// Copyright (C) 2017-present Instructure, Inc.
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

import CoreData


final public class FileUploadBatch: NSManagedObject {
    @NSManaged open internal(set) var primitiveFileTypes: String
    open internal(set) var fileTypes: [String] {
        get {
            return primitiveFileTypes.components(separatedBy: ",")
        }
        set {
            primitiveFileTypes = newValue.joined(separator: ",")
        }
    }

    @NSManaged open internal(set) var apiPath: String

    @NSManaged open internal(set) var fileUploads: Set<FileUpload>


    public convenience init(session: Session, fileTypes: [String], apiPath: String) {
        let context = try! session.filesManagedObjectContext()
        self.init(inContext: context)

        self.fileTypes = fileTypes
        self.apiPath = apiPath
    }
}
