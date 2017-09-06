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
  group_conversation?: boolean, // hard coded as `true`
  attachment_ids?: string[],
  media_comment_id?: string,
  media_comment_type?: string,
  user_note?: boolean,
  context_code?: string,
  bulk_message?: number, // `undefined` for group, `1` for send individually
}

export type AddMessageParameters = {
  recipients: string[],
  body: string,
}

type InboxScope = 'all' | 'unread' | 'starred' | 'sent' | 'archived'
