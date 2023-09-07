//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import mobile_offline_downloader_ios

extension File: OfflineStorageDataProtocol {
    public static func fromOfflineModel(_ model: OfflineStorageDataModel) throws -> File {
        let env = AppEnvironment.shared
        if model.type == OfflineContentType.file.rawValue {
            let data = model.json.data(using: .utf8)
            let context = env.database.viewContext
            let predicate = NSPredicate(format: "%K == %@", #keyPath(File.id), model.id)
            if let file: File = context.fetch(predicate).first { return file }
        }

        throw OfflineStorageDataError.cantCreateObject(type: File.self)
    }

    public func toOfflineModel() throws -> OfflineStorageDataModel {
        let dictionary: [String: Any?] = [
            "assignmentID": assignmentID,
            "batchID": batchID,
            "bytesSent": bytesSent,
            "contentType": contentType,
            "contextRaw": contextRaw,
            "id": id,
            "uuid": uuid,
            "folderID": folderID,
            "displayName": displayName,
            "filename": filename,
            "url": url?.absoluteString,
            "size": size,
            "createdAt": createdAt?.timeIntervalSince1970,
            "updatedAt": updatedAt?.timeIntervalSince1970,
            "unlockAt": unlockAt?.timeIntervalSince1970,
            "locked": locked,
            "hidden": hidden,
            "lockAt": lockAt?.timeIntervalSince1970,
            "hiddenForUser": hiddenForUser,
            "thumbnailURL": thumbnailURL?.absoluteString,
            "modifiedAt": modifiedAt?.timeIntervalSince1970,
            "mimeClass": mimeClass,
            "mediaEntryID": mediaEntryID,
            "lockedForUser": lockedForUser,
            "lockExplanation": lockExplanation,
            "previewURL": previewURL?.absoluteString,
            "localFileURL": localFileURL?.absoluteString,
            "uploadError": uploadError,
            "taskID": taskID,
            "userID": userID,
            "similarityScore": similarityScore,
            "similarityStatus": similarityStatus,
            "similarityURL": similarityURL?.absoluteString,
            "courseID": courseID
        ]
        if let id = id, let jsonData = try? JSONSerialization.data(withJSONObject: dictionary),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return OfflineStorageDataModel(
                id: id,
                type: OfflineContentType.file.rawValue,
                json: jsonString
            )
        }
        return OfflineStorageDataModel(id: "", type: "", json: "")
    }
}
