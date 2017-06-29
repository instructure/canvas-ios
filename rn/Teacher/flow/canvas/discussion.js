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
