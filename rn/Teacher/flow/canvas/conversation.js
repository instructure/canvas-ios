// @flow

export type Conversation = {
  id: string,
  subject: string,
  workflow_state: 'read' | 'unread' | 'archived',
  last_message: string,
  last_message_at: string,
  participants: ConversationParticipant[],
  message_count: number,
  subscribed: boolean,
  private: boolean,
  starred: boolean,
  properties: any,
  audience: string[],
  audience_contexts: any,
  avatar_url: string,
  visible: true,
  context_name: string,
  messages?: ConversationMessage[],
}

export type ConversationParticipant = {
  id: string,
  name: string,
  avatar_url?: ?string,
}

export type ConversationMessage = {
  id: string,
  created_at: string,
  body: string,
  author_id: string,
  generated: boolean,
  media_comment: any,
  forwarded_messages: any,
  attachments: any,
}
