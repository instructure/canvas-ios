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
  entry_ratings: { [string]: number },
}

export type DiscussionReply = {
  created_at: string,
  id: string,
  message: ?string,
  parent_id: ?string,
  rating_count: ?number,
  rating_sum: ?number,
  replies: DiscussionReply[],
  updated_at: string,
  user_id: string,
  deleted?: boolean,
  attachment?: ?Attachment,
  pendng?: boolean,
  editor_id?: string,
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
  permissions: DiscussionPermissions,
  message: string,
  assignment?: ?Assignment,
  discussion_subentry_count: number,
  last_reply_at: string,
  replies?: ?DiscussionReply[],
  participants?: ?{ [key: string]: UserDisplay },
  author: UserDisplay,
  allow_rating: boolean,
  only_graders_can_rate: boolean,
  require_initial_post: boolean,
  delayed_post_at?: ?string,
  attachments?: ?Attachment[],
  discussion_type: DiscussionType,
  unlock_at?: ?string,
  can_unpublish: boolean,
  locked_for_user?: boolean,
  locked?: boolean,
  sections?: Section[],
  is_section_specific: boolean,
}

// api params

export type GetDiscussionsParameters = {
  only_announcements?: boolean,
}

export type CreateDiscussionParameters = {
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
  specific_sections?: string,
  sections?: Section[],
  group_topic_children?: DiscussionGroupTopicChildren[],
}

export type UpdateDiscussionParameters = CreateDiscussionParameters & {
  id: string,
}

export type CreateEntryParameters = {
  message: string,
  attachment?: ?Attachement,
}

export type DiscussionOriginEntity = CourseState | GroupState

export type DiscussionGroupTopicChildren = {
  id: string,
  group_id: string,
}
