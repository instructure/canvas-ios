/* @flow */
import { paginate } from '../utils/pagination'
import httpClient from './httpClient'

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

export function createConversation (conversation: CreateConversationParameters): Promise<ApiResponse<Conversation>> {
  const url = 'conversations'
  return httpClient().post(url, conversation)
}

export function markConversationAsRead (conversationID: string): Promise<ApiResponse<Conversation>> {
  const url = `conversations/${conversationID}`
  const conversation = {
    id: conversationID,
    workflow_state: 'read',
  }
  return httpClient().put(url, { conversation })
}
