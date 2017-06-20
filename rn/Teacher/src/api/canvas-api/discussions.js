/* @flow */

import httpClient from './httpClient'
import { paginate, exhaust } from '../utils/pagination'

type GetDiscussionsParameters = {
  only_announcents?: boolean,
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
}

export type UpdateDiscussionParameters = CreateDiscussionParameters & {
  id: string,
}

export type CreateEntryParameters = {
  message: string,
  attachment?: string,
}

export function getDiscussions (courseID: string, parameters: GetDiscussionsParameters = {}): Promise<ApiResponse<Discussion[]>> {
  const url = `courses/${courseID}/discussion_topics`
  const options = {
    params: {
      per_page: 99,
      ...parameters,
    },
  }
  let discussions = paginate(url, options)
  return exhaust(discussions)
}

export function getAllDiscussionEntries (courseID: string, discussionID: string, includeNewEntries: boolean): Promise<ApiResponse<DiscussionView>> {
  const parameters = includeNewEntries ? '?include_new_entries=1' : ''
  const url = `courses/${courseID}/discussion_topics/${discussionID}/view${parameters}`
  return httpClient().get(url)
}

export function getDiscussion (courseID: string, discussionID: string): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics/${discussionID}`
  return httpClient().get(url)
}

export function createDiscussion (courseID: string, parameters: CreateDiscussionParameters): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics`
  return httpClient().post(url, parameters)
}

export function createEntry (courseID: string, discussionID: string, parameters: CreateEntryParameters): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics/${discussionID}/entries`
  return httpClient().post(url, parameters)
}

export function updateDiscussion (courseID: string, parameters: UpdateDiscussionParameters): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics/${parameters.id}`
  return httpClient().put(url, parameters)
}

export function deleteDiscussionEntry (courseID: string, discussionID: string, entryID: string): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics/${discussionID}/entries/${entryID}`
  return httpClient().delete(url, {})
}

export function deleteDiscussion (courseID: string, discussionID: string): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics/${discussionID}`
  return httpClient().delete(url)
}

export function subscribeDiscussion (courseID: string, discussionID: string, subscribed: boolean): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics/${discussionID}/subscribed`
  return httpClient()[subscribed ? 'put' : 'delete'](url)
}
