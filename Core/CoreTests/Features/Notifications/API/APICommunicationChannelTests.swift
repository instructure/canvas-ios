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

import XCTest
@testable import Core

class APICommunicationChannelTests: CoreTestCase {
    func testChannelTypeName() {
        XCTAssertEqual(CommunicationChannelType.chat.name, "Chat Notifications")
        XCTAssertEqual(CommunicationChannelType.email.name, "Email Notifications")
        XCTAssertEqual(CommunicationChannelType.push.name, "Push Notifications")
        XCTAssertEqual(CommunicationChannelType.slack.name, "Slack Notifications")
        XCTAssertEqual(CommunicationChannelType.sms.name, "SMS Notifications")
        XCTAssertEqual(CommunicationChannelType.twitter.name, "Twitter Notifications")
        XCTAssertEqual(CommunicationChannelType.yo.name, "Yo Notifications")
    }
}
