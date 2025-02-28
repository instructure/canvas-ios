//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public struct GetInboxSettingsRequest: APIGraphQLRequestable {
    public typealias Response = APIInboxSettings

    public struct Variables: Codable, Equatable {
    }
    public let variables: Variables

    public init() {
        variables = Variables()
    }

    static let operationName = "InboxSettings"
    static let query = """
        query \(operationName) {
          myInboxSettings {
                _id
                createdAt
                outOfOfficeLastDate
                outOfOfficeMessage
                outOfOfficeSubject
                outOfOfficeFirstDate
                signature
                updatedAt
                useOutOfOffice
                useSignature
                userId
          }
        }
        """
}

public struct APIInboxSettings: Codable, Equatable {
    let data: APIInboxSettings.MyInboxSettings

    struct MyInboxSettings: Codable, Equatable {
        let myInboxSettings: APIInboxSettings.Data
    }

    struct Data: Codable, Equatable {
        let _id: String?
        let createdAt: Date?
        let outOfOfficeLastDate: Date?
        let outOfOfficeMessage: String?
        let outOfOfficeSubject: String?
        let outOfOfficeFirstDate: Date?
        let signature: String?
        let updatedAt: Date?
        let useOutOfOffice: Bool?
        let useSignature: Bool?
        let userId: String?
    }
}
