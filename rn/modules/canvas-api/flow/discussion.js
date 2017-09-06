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

export type DiscussionPermissions = {
  attach: boolean,
  delete: boolean,
  reply: boolean,
  update: boolean,
}

export type DiscussionView = {
  unread_entries: string[],
  participants: UserDisplay[],
  view: DiscussionReply[],
  new_entries: string[],
}

export type DiscussionReply = {
  created_at: string,
  id: string,
  message: string,
  parent_id: ?string,
  rating_count: ?number,
  rating_sum: ?number,
  replies: DiscussionReply[],
  updated_at: string,
  user_id: string,
  deleted: boolean,
  attachment: ?Attachment,
  pendng?: boolean,
  editor_id: string,
}

export type DiscussionType = 'side_comment' | 'threaded'

export type Discussion = {
  id: string,
  assignment_id?: ?string,
  title: string,
  html_url: string,
  pinned: boolean,
  position: number,
  posted_at: string,
  published: boolean,
  read_state: null | 'read',
  sort_by_rating: boolean,
  subscribed: boolean,
  user_can_see_posts: boolean,
  user_name: string,
  unread_count: number,
  permissions: DiscussionPermissions[],
  message: string,
  assignment: ?Assignment,
  discussion_subentry_count: number,
  last_reply_at: string,
  replies: ?DiscussionReply[],
  participants: ?{ [key: string]: UserDisplay },
  author: UserDisplay,
  allow_rating: boolean,
  only_graders_can_rate: boolean,
  require_initial_post: boolean,
  delayed_post_at: ?string,
  attachments: ?Attachment[],
  discussion_type: DiscussionType,
  unlock_at: ?string,
  can_unpublish: boolean,
}


// api params

type GetDiscussionsParameters = {
  only_announcents?: boolean,
}

type CreateDiscussionParameters = {
  title?: string,
  message: string,
  allow_rating?: boolean,
  only_graders_can_rate?: boolean,
  sort_by_rating?: boolean,
  require_initial_post?: boolean,
  delayed_post_at?: ?string,
  is_announcement?: boolean,
  locked?: boolean,
  pinned?: boolean,
  published?: boolean,
  discussion_type?: DiscussionType,
  subscribed?: boolean,
  attachment?: ?Attachment,
  remove_attachment?: boolean,
}

type UpdateDiscussionParameters = CreateDiscussionParameters & {
  id: string,
}

type CreateEntryParameters = {
  message: string,
  attachment?: string,
}