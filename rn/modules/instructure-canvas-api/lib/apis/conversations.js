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

/* @flow */
import { paginate } from '../utils/pagination'
import httpClient from '../httpClient'

export function getUnreadConversationsCount (): Promise<ApiResponse<{ unread_count: number }>> {
  const url = 'conversations/unread_count'
  return httpClient().get(url)
}

export function getConversations (scope: InboxScope): Promise<ApiResponse<Conversation>> {
  const url = 'conversations'
  const params: { [string]: any } = {
    per_page: 50,
    include: ['participant_avatars'],
  }

  if (scope !== 'all') {
    params.scope = scope
  }

  return paginate(url, { params })
}

export function getConversationDetails (conversationID: string): Promise<ApiResponse<Conversation>> {
  const url = `conversations/${conversationID}`
  const params = {
    include: ['participant_avatars'],
  }
  return httpClient().get(url, { params })
}

export function starConversation (conversationID: string): Promise<ApiResponse<Conversation>> {
  const url = `conversations/${conversationID}`
  const conversation = {
    id: conversationID,
    starred: true,
  }
  return httpClient().put(url, { conversation })
}

export function unstarConversation (conversationID: string): Promise<ApiResponse<Conversation>> {
  const url = `conversations/${conversationID}`
  const conversation = {
    id: conversationID,
    starred: false,
  }
  return httpClient().put(url, { conversation })
}

export function deleteConversation (conversationID: string): Promise<ApiResponse<Conversation>> {
  return httpClient().delete(`conversations/${conversationID}`)
}

export function deleteConversationMessage (conversationID: string, messageID: string): Promise<ApiResponse<>> {
  return httpClient().post(`conversations/${conversationID}/remove_messages`, {
    remove: [messageID],
  })
}

export function createConversation (conversation: CreateConversationParameters): Promise<ApiResponse<Conversation>> {
  const url = 'conversations'
  return httpClient().post(url, conversation)
}

export function addMessage (conversationID: string, message: CreateConversationParameters): Promise<ApiResponse<Conversation>> {
  return httpClient().post(`conversations/${conversationID}/add_message`, message)
}

export function markConversationAsRead (conversationID: string): Promise<ApiResponse<Conversation>> {
  const url = `conversations/${conversationID}`
  const conversation = {
    id: conversationID,
    workflow_state: 'read',
  }
  return httpClient().put(url, { conversation })
}
