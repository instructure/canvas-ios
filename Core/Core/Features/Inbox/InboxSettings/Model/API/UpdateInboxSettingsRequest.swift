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

import Foundation

public struct UpdateInboxSettingsRequest: APIGraphQLRequestable {
    public typealias Response = APIUpdateInboxSettings

    public struct Input: Codable, Equatable {
        let outOfOfficeLastDate: Date?
        let outOfOfficeMessage: String?
        let outOfOfficeSubject: String?
        let outOfOfficeFirstDate: Date?
        let signature: String?
        let useOutOfOffice: Bool?
        let useSignature: Bool?
    }

    public struct Variables: Codable, Equatable {
        var input: Input
    }
    public let variables: Variables

    public init(input: Input) {
        variables = Variables(input: input)
    }

    public init(inboxSettings: CDInboxSettings) {
        let input = Input(
            outOfOfficeLastDate: inboxSettings.outOfOfficeLastDate,
            outOfOfficeMessage: inboxSettings.outOfOfficeMessage,
            outOfOfficeSubject: inboxSettings.outOfOfficeSubject,
            outOfOfficeFirstDate: inboxSettings.outOfOfficeFirstDate,
            signature: inboxSettings.signature,
            useOutOfOffice: inboxSettings.useOutOfOffice,
            useSignature: inboxSettings.useSignature
        )
        self.init(input: input)
    }

    static let operationName = "InboxSettings"
    static let query = """
        mutation \(operationName)($input: UpdateMyInboxSettingsInput!) {
          updateMyInboxSettings(input: $input) {
            myInboxSettings {
                createdAt
                outOfOfficeLastDate
                outOfOfficeMessage
                outOfOfficeSubject
                outOfOfficeFirstDate
                signature
                updatedAt
                useOutOfOffice
                useSignature
            }
          }
        }
        """
}
