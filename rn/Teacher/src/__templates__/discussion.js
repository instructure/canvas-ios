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
import { assignment } from './assignments'
import { userDisplay } from './users'

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
  author: userDisplay(),
  allow_rating: false,
  only_graders_can_rate: false,
  require_initial_post: false,
  delayed_post_at: null,
  discussion_type: 'side_comment',
  unlock_at: null,
  can_unpublish: true,
  is_section_specific: false,
})

export const discussionReply: Template<DiscussionReply> = template({
  'id': '25472827',
  'user_id': userDisplay().id,
  'parent_id': null,
  'created_at': '2017-05-23T17:12:04Z',
  'updated_at': '2017-05-23T17:12:04Z',
  'rating_count': null,
  'rating_sum': null,
  'message': '<p>1.0</p>',
  'replies': [],
})

export const discussionEditReply: Template<DiscussionReply> = template({
  'id': '25472827',
  'editor_id': '1',
  'user_id': '1',
  'parent_id': null,
  'created_at': '2017-05-23T17:12:04Z',
  'updated_at': '2017-05-23T17:12:04Z',
  'rating_count': null,
  'rating_sum': null,
  'message': '<p>2.0</p>',
  'replies': [],
})

export const discussionView: Template<DiscussionView> = template({
  'new_entries': [],
  'unread_entries': [
    '25458826',
    '25458830',
  ],
  entry_ratings: {},
  participants: [userDisplay()],
  'view': [
    discussionReply({
      'id': '25472827',
      'user_id': '1',
      'parent_id': null,
      'created_at': '2017-05-23T17:12:04Z',
      'updated_at': '2017-05-23T17:12:04Z',
      'rating_count': null,
      'rating_sum': null,
      'message': '<p>1.0</p>',
      'replies': [],
    }),
  ],
})

export const discussionViewLarge: Template<DiscussionView> = template({
  'new_entries': [],
  'unread_entries': [
    '25458826',
    '25458830',
  ],
  'entry_ratings': {
    '4': 1,
  },
  participants: [userDisplay()],
  'view': [
    discussionReply({
      'id': '25472827',
      'user_id': '5347622',
      'parent_id': null,
      'created_at': '2017-05-23T17:12:04Z',
      'updated_at': '2017-05-23T17:12:04Z',
      'rating_count': null,
      'rating_sum': null,
      'message': '<p>1.0</p>',
      'replies': [
        discussionReply({
          'id': '25472860',
          'user_id': '5347622',
          'parent_id': '25472827',
          'created_at': '2017-05-23T17:14:43Z',
          'updated_at': '2017-05-23T17:14:43Z',
          'rating_count': null,
          'rating_sum': null,
          'message': '<p>1.1</p>',
        }),
        discussionReply({
          'id': '25472862',
          'user_id': '5347622',
          'parent_id': '25472827',
          'created_at': '2017-05-23T17:14:51Z',
          'updated_at': '2017-05-23T17:14:51Z',
          'rating_count': null,
          'rating_sum': null,
          'message': '<p>1.2</p>',
        }),
      ],
    }),
    discussionReply({
      'id': '25472831',
      'user_id': '5347622',
      'parent_id': null,
      'created_at': '2017-05-23T17:12:15Z',
      'updated_at': '2017-05-23T17:12:15Z',
      'rating_count': null,
      'rating_sum': null,
      'message': '<p>2.0</p>',
      'replies': [
        {
          'id': '25472941',
          'user_id': '5347622',
          'parent_id': '25472831',
          'created_at': '2017-05-23T17:20:43Z',
          'updated_at': '2017-05-23T17:20:43Z',
          'rating_count': null,
          'rating_sum': null,
          'message': '<p>Myself</p>',
          'attachment': {
            'id': '107777279',
            'folder_id': '6852597',
            'display_name': 'profile_photo.jpg',
            'filename': 'profile_photo.jpg',
            'content-type': 'image/jpeg',
            'url': 'https://mobiledev.instructure.com/files/107777279/download?download_frd=1&verifier=IL9TUHoM8P5RsPUSASyZEYv6mOkhAqUR3fBOPvt5',
            'size': 416708,
            'created_at': '2017-05-23T17:20:43Z',
            'updated_at': '2017-05-23T17:20:43Z',
            'unlock_at': null,
            'locked': false,
            'hidden': false,
            'lock_at': null,
            'hidden_for_user': false,
            'thumbnail_url': 'https://instructure-uploads.s3.amazonaws.com/account_99298/thumbnails/88538243/profile_photo_thumb.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAJFNFXH2V2O7RPCAA%2F20170523%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20170523T172053Z&X-Amz-Expires=518400&X-Amz-SignedHeaders=host&X-Amz-Signature=d67a6925ea4316318cd5328baa8db3199b41cd3f5119acbda3e0feddf7bfb225',
            'modified_at': '2017-05-23T17:20:43Z',
            'mime_class': 'image',
            'media_entry_id': null,
            'locked_for_user': false,
          },
        },
      ],
    })],
})

export const createDiscussionParams: Template<CreateDiscussionParameters> = template({
  title: 'Infernal Shrines',
  message: 'Summon a mighty Punisher',
  allow_rating: false,
  only_graders_can_rate: false,
  sort_by_rating: false,
  require_initial_post: false,
  delayed_post_at: null,
  is_announcement: false,
})

export const updateDiscussionParams: Template<UpdateDiscussionParameters> = template({
  id: '1',
  ...createDiscussionParams(),
})

export const discussionPermissions: Template<CoursePermissions> = template({
  create_announcement: true,
  create_discussion_topic: true,
})
