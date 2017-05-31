/* @flow */

import template, { type Template } from '../../../utils/template'
import { assignment } from './assignments'

export const discussion: Template<Discussion> = template({
  id: '1',
  assignment_id: assignment().id,
  title: 'Dear Ivy Iversen, your last name cannot start with your first name',
  html_url: 'http://mobiledev.instructure.com/courses/1/discussion_topics',
  pinned: false,
  position: 1,
  posted_at: '2016-11-11T04:03:17Z',
  published: true,
  read_state: 'read',
  sort_by_rating: false,
  subscribed: true,
  user_can_see_posts: true,
  user_name: 'Ivy Iversen',
  unread_count: 1,
  discussion_subentry_count: 2,
  permissions: {
    'attach': true,
    'delete': true,
    'reply': true,
    'update': true,
  },
  message: '<p>And why?</p>',
  assignment: assignment(),
  last_reply_at: '2016-12-11T04:03:17Z',
})
