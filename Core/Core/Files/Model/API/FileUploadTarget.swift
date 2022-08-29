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

import Foundation

/**
 This class can be stored in CoreData because it conforms to `NSObject` and `Codable` and all of its properties
 are supported by `NSSecureUnarchiveFromDataTransformer`.
 */
public class FileUploadTarget: NSObject, Codable {
    public let upload_url: URL
    public let upload_params: [String: String?]

    public init(upload_url: URL, upload_params: [String: String?]) {
        self.upload_url = upload_url
        self.upload_params = upload_params
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? FileUploadTarget else { return false }
        return upload_url == rhs.upload_url && upload_params == rhs.upload_params
    }
}
