//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import CoreUITests
@testable import Core
@testable import TestsFoundation

class InboxTests: ParentUITestCase {
    func testReplyWithAttachments() {
        mockBaseRequests()
        let message = APIConversationMessage.make(
            id: "1",
            body: "Reply to this message"
        )
        let newMessage = APIConversationMessage.make(
            id: "2",
            body: "This is a reply with attachments"
        )
        let conversation = APIConversation.make(id: "1", messages: [message])
        mockData(GetConversationsRequest(include: [.participant_avatars], perPage: 100, scope: nil, filter: nil), value: [conversation])
        mockData(GetConversationsRequest(include: [.participant_avatars], perPage: 100, scope: .sent, filter: nil), value: [])
        mockData(GetConversationRequest(id: conversation.id.value, include: [.participant_avatars]), value: conversation)
        let target = FileUploadTarget.make()
        mockData(PostFileUploadTargetRequest(
            context: .myFiles,
            body: .init(name: "", on_duplicate: .overwrite, parent_folder_id: nil, size: 0)
        ), value: target)
        let file = APIFile.make(id: "1", display_name: "Compose Attachment", mime_class: "image")
        let fileURL = URL(string: "data:text/plain,")!
        mockData(PostFileUploadRequest(fileURL: fileURL, target: target), value: file)
        mockData(URLRequest(url: file.url!.rawValue), value: try! Data(contentsOf: fileURL))
        mockData(GetFileRequest(context: .user("self"), fileID: file.id.value, include: []), value: file)
        mockData(PostAddMessageRequest(conversationID: conversation.id.value, body: .init(
            attachment_ids: [file.id.value],
            body: newMessage.body,
            media_comment_id: nil,
            media_comment_type: nil,
            recipients: nil
        )), value: .make(
            id: conversation.id.value,
            messages: [message, newMessage]
        ))

        logIn()
        Dashboard.profileButton.tap()
        Profile.inboxButton.tap()
        ConversationList.cell(id: conversation.id.value).tap()
        ConversationDetail.replyButton.tapUntil {
            ComposeReply.body.exists()
        }
        ComposeReply.body.typeText(newMessage.body)
        ComposeReply.attachButton.tap()
        allowAccessToPhotos {
            app.find(label: "Photo Library").tap()
        }
        let photo = app.find(labelContaining: "Photo, ")
        app.find(label: "All Photos").tapUntil { photo.exists }
        photo.tap()
        ComposeReply.attachmentCard(index: 0).waitToExist()
        app.find(label: "Compose Attachment").waitToExist()
        ComposeReply.sendButton.tap()
        ConversationDetail.cell(id: "2").waitToExist()
        app.find(label: newMessage.body).waitToExist()
    }
}
