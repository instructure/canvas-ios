/* @flow */

import httpClient from './httpClient'
import { paginate, exhaust } from '../utils/pagination'

type GetDiscussionsParameters = {
  only_announcents?: boolean,
}

export type CreateDiscussionParameters = {
  title: string,
  message: string,
  allow_rating: boolean,
  only_graders_can_rate: boolean,
  sort_by_rating: boolean,
  require_initial_post: boolean,
  delayed_post_at: ?string,
  is_announcement: boolean,
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

export function updateDiscussion (courseID: string, discussion: Discussion): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics/${discussion.id}`
  return httpClient().put(url, { ...discussion })
}

export function getAllDiscussionEntries (courseID: string, discussionID: string): Promise<ApiResponse<DiscussionView>> {
  const url = `courses/${courseID}/discussion_topics/${discussionID}/view`
  return httpClient().get(url)
}

export function createDiscussion (courseID: string, parameters: CreateDiscussionParameters): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics`
  return httpClient().post(url, parameters)
}
