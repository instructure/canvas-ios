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
})
