// @flow

export type Conversation = {
  id: string,
  subject: string,
  workflow_state: 'read' | 'unread' | 'archived',
  last_message: string,
  last_message_at: string,
  last_authored_message: string,
  last_authored_message_at: string,
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
  context_code: string,
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
  attachments: ?Attachment[],
}

export type CreateConversationParameters = {
  recipients: string[],
  body: string,
  subject?: string,
  group_conversation?: boolean,
  attachment_ids?: string[],
  media_comment_id?: string,
  media_comment_type?: string,
  user_note?: boolean,
  context_code?: string,
}

export type AddMessageParameters = {
  recipients: string[],
  body: string,
}
