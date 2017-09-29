//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SoGrey

class InboxPage {

    // MARK: Singleton

    static let sharedInstance = InboxPage()
    private let tabBarController = TabBarControllerPage.sharedInstance
    private init() {}

    // MARK: Elements

    private let newMessageButton = e.selectBy(id: "inbox.new-message")
    private let filterAllButton = e.selectBy(id: "inbox.filter-btn-all")
    private let filterUnreadButton = e.selectBy(id: "inbox.filter-btn-unread")
    private let filterStarredButton = e.selectBy(id: "inbox.filter-btn-starred")
    private let filterSentButton = e.selectBy(id: "inbox.filter-btn-sent")
    private let filterArchivedButton = e.selectBy(id: "inbox.filter-btn-archived")

    // MARK: - Assertions

    func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        tabBarController.assertTabBarItems()
        newMessageButton.assertExists()
        filterAllButton.assertExists()
        filterUnreadButton.assertExists()
        filterStarredButton.assertExists()
        filterSentButton.assertExists()
        filterArchivedButton.assertExists()
    }
}
