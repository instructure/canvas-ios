//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import { paginate } from '../utils/pagination'
import httpClient from '../httpClient'

export function getUnreadConversationsCount (): ApiPromise<{ unread_count: number }> {
  const url = 'conversations/unread_count'
  return httpClient().get(url)
}

export function getConversations (scope: InboxScope): ApiPromise<Conversation> {
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

export function getConversationDetails (conversationID: string): ApiPromise<Conversation> {
  const url = `conversations/${conversationID}`
  const params = {
    include: ['participant_avatars'],
  }
  return httpClient().get(url, { params })
}

export function starConversation (conversationID: string): ApiPromise<Conversation> {
  const url = `conversations/${conversationID}`
  const conversation = {
    id: conversationID,
    starred: true,
  }
  return httpClient().put(url, { conversation })
}

export function unstarConversation (conversationID: string): ApiPromise<Conversation> {
  const url = `conversations/${conversationID}`
  const conversation = {
    id: conversationID,
    starred: false,
  }
  return httpClient().put(url, { conversation })
}

export function deleteConversation (conversationID: string): ApiPromise<Conversation> {
  return httpClient().delete(`conversations/${conversationID}`)
}

export function deleteConversationMessage (conversationID: string, messageID: string): ApiPromise<null> {
  return httpClient().post(`conversations/${conversationID}/remove_messages`, {
    remove: [messageID],
  })
}

export function createConversation (conversation: CreateConversationParameters): ApiPromise<Conversation> {
  const url = 'conversations'
  return httpClient().post(url, conversation)
}

export function addMessage (conversationID: string, message: CreateConversationParameters): ApiPromise<Conversation> {
  return httpClient().post(`conversations/${conversationID}/add_message`, message)
}

export function markConversationAsRead (conversationID: string): ApiPromise<Conversation> {
  const url = `conversations/${conversationID}`
  const conversation = {
    id: conversationID,
    workflow_state: 'read',
  }
  return httpClient().put(url, { conversation })
}
