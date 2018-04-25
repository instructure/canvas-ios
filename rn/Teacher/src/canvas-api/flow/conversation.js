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
  media_comment?: MediaComment,
  forwarded_messages?: any,
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

export type InboxScope = 'all' | 'unread' | 'starred' | 'sent' | 'archived'
