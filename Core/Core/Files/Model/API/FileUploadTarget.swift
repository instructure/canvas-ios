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
 This class can be stored in CoreData by using `FileUploadTargetTransformer`.
 */
public class FileUploadTarget: NSObject, Codable, NSSecureCoding {
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

    // MARK: - NSSecureCoding Protocol

    public static var supportsSecureCoding: Bool { true }

    public required init?(coder: NSCoder) {
        guard
            let upload_url = coder.decodeObject(of: NSURL.self, forKey: "upload_url") as? URL,
            let upload_params = coder.decodeObject(of: [NSDictionary.self, NSString.self, NSNull.self], forKey: "upload_params") as? [String: String?]
        else {
            return nil
        }

        self.upload_url = upload_url
        self.upload_params = upload_params
    }

    public func encode(with coder: NSCoder) {
        coder.encode(upload_url, forKey: "upload_url")
        coder.encode(upload_params, forKey: "upload_params")
    }
}

class FileUploadTargetTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: FileUploadTargetTransformer.self))
    override static var allowedTopLevelClasses: [AnyClass] { [FileUploadTarget.self] }

    static func register() {
        let transformer = FileUploadTargetTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
