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

import Combine
import CombineExt

public class ComposeMessageInteractorLive: ComposeMessageInteractor {
    public func createConversation(parameters: MessageParameters) -> Future<Void, Error> {
        Future<Void, Error> { promise in
            CreateConversation(
                subject: parameters.subject,
                body: parameters.body,
                recipientIDs: parameters.recipientIDs,
                canvasContextID: parameters.context.canvasContextID,
                attachmentIDs: parameters.attachmentIDs,
                groupConversation: parameters.groupConversation
            )
            .fetch { _, _, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }

    public func addConversationMessage(parameters: MessageParameters) -> Future<Void, Error> {
        Future<Void, Error> { promise in
            if let conversationID = parameters.conversationID {
                AddMessage(
                    conversationID: conversationID,
                    attachmentIDs: parameters.attachmentIDs,
                    body: parameters.body,
                    recipientIDs: parameters.recipientIDs,
                    includedMessages: parameters.includedMessages
                )
                .fetch { _, _, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } else {
                promise(.failure(NSError.instructureError("Invalid conversation ID")))
            }
        }
    }
}
