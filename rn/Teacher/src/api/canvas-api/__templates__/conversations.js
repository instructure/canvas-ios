/* @flow */

import template, { type Template } from '../../../utils/template'

export const conversation: Template<Conversation> = template({
  id: '123456789',
  subject: 'learn to write code',
  workflow_state: 'read',
  last_message: 'this is the worst class ever',
  last_message_at: '2037-06-01T05:59:00Z',
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
})

export const conversationMessage: Template<ConversationMessage> = template({
  id: '123456789',
  body: 'this is neat',
  author_id: '1234',
  attachments: [
    {
      id: '1',
      display_name: 'something.pdf',
      mime_class: 'pdf',
    },
  ],
})
