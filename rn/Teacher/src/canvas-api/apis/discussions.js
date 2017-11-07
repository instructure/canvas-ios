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

/* @flow */

import httpClient from '../httpClient'
import { paginate, exhaust } from '../utils/pagination'

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

export function getAllDiscussionEntries (courseID: string, discussionID: string, includeNewEntries: boolean = true): Promise<ApiResponse<DiscussionView>> {
  const options = {
    params: { include_new_entries: includeNewEntries ? 1 : 0 },
  }
  const url = `courses/${courseID}/discussion_topics/${discussionID}/view`
  return httpClient().get(url, options)
}

export function getDiscussion (courseID: string, discussionID: string): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics/${discussionID}`
  return httpClient().get(url)
}

export function createDiscussion (courseID: string, parameters: CreateDiscussionParameters): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics`
  const formdata = discussionFormData(parameters)
  return httpClient().post(url, formdata)
}

export function createEntry (courseID: string, discussionID: string, entryID: string = '', parameters: CreateEntryParameters): Promise<ApiResponse<Discussion>> {
  const url = entryID ? `courses/${courseID}/discussion_topics/${discussionID}/entries/${entryID}/replies` : `courses/${courseID}/discussion_topics/${discussionID}/entries`
  return httpClient().post(url, parameters)
}

export function editEntry (courseID: string, discussionID: string, entryID: string, parameters: CreateEntryParameters): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics/${discussionID}/entries/${entryID}`
  return httpClient().put(url, parameters)
}

export function updateDiscussion (courseID: string, parameters: UpdateDiscussionParameters): Promise<ApiResponse<Discussion>> {
  const url = `courses/${courseID}/discussion_topics/${parameters.id}`
  const formdata = discussionFormData(parameters)
  return httpClient().put(url, formdata)
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

export function markEntryAsRead (courseID: string, discussionID: string, entryID: string): Promise<ApiResponse<>> {
  const url = `courses/${courseID}/discussion_topics/${discussionID}/entries/${entryID}/read`
  return httpClient().put(url)
}

export function markAllAsRead (courseID: string, discussionID: string): Promise<ApiResponse<>> {
  const url = `courses/${courseID}/discussion_topics/${discussionID}/read_all`
  return httpClient().put(url)
}

function discussionFormData (parameters: CreateDiscussionParameters | UpdateDiscussionParameters): FormData {
  const formdata = new FormData()
  Object.keys(parameters)
    .filter(k => k !== 'attachment')
    // $FlowFixMe
    .forEach(key => formdata.append(key, parameters[key]))
  if (parameters.attachment && parameters.attachment.uri) {
    const { uri, display_name } = parameters.attachment
    // $FlowFixMe
    formdata.append('attachment', { uri, name: display_name, type: 'multipart/form-data' })
  }
  return formdata
}
