//
// Copyright (C) 2019-present Instructure, Inc.
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

import XCTest
import TestsFoundation

class DiscussionDetailsTests: CanvasUITests {
    func testPreviewAttachment() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.discussions.tap()

        DiscussionList.cell(index: 0).tapUntil {
            DiscussionDetails.attachmentButton.exists
        }

        DiscussionDetails.attachmentButton.tap()
        app.find(id: "attachment-view.share-btn").waitToExist()
    }
}
