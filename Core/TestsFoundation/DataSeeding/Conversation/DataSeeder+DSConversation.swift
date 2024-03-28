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

extension DataSeeder {
    @discardableResult
    public func createConversation(requestBody: CreateDSConversationRequest.RequestedDSConversation) -> DSConversation {
        let request = CreateDSConversationRequest(body: requestBody)
        return makeRequest(request)[0]
    }

    @discardableResult
    public func updateConversation(conversationId: String, event: DSEvent) -> DSProgress {
        let requestedBody = UpdateDSConversationRequest.Body(conversation_ids: [conversationId], event: event)
        let request = UpdateDSConversationRequest(body: requestedBody)
        return makeRequest(request)
    }

    public func editConversation(conversationId: String, workflowState: DSWorkFlowState, scope: DSScope) -> DSConversation {
        let requestedBody = EditDSConversationRequest.Body(conversation: .init(workflow_state: workflowState), scope: scope)
        let reqest = EditDSConversationRequest(body: requestedBody, conversationId: conversationId)
        return makeRequest(reqest)
    }

    @discardableResult
    public func getProgress(progressId: String) -> DSProgress {
        return makeRequest(GetDSProgressRequest(progressId: progressId))
    }
}
