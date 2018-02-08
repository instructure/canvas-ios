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

/* @flow */

import template, { type Template } from '../utils/template'

export const conversation: Template<Conversation> = template({
  id: '123456789',
  subject: 'learn to write code',
  workflow_state: 'read',
  last_message: 'this is the worst class ever',
  last_message_at: '2037-06-01T05:59:00Z',
  last_authored_message: 'this is the worst class ever',
  last_authored_message_at: '2037-06-01T05:59:00Z',
  participants: [
    {
      id: '1234',
      name: 'artorias of the abyss',
    },
    {
      id: '6789',
      name: 'solaire of astora',
    },
  ],
  avatar_url: 'http://www.fillmurray.com/200/300',
  context_name: 'Test Class',
  context_code: 'course_1',
  audience_contexts: {},
  audience: [],
  message_count: 2,
  private: false,
  properties: null,
  starred: false,
  subscribed: false,
  visible: true,
})

export const conversationMessage: Template<ConversationMessage> = template({
  id: '123456789',
  body: 'this is neat',
  author_id: '1234',
  created_at: '2037-06-01T05:59:00Z',
  attachments: [
    {
      id: '1',
      display_name: 'something.pdf',
      mime_class: 'pdf',
    },
  ],
  generated: false,
})
