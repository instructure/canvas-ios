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

import httpClient from '../httpClient'
import { paginate, exhaust } from '../utils/pagination'

export function getDiscussions (context: CanvasContext, contextID: string, parameters: GetDiscussionsParameters = {}): ApiPromise<Discussion[]> {
  const url = `${context}/${contextID}/discussion_topics`
  const options = {
    params: {
      per_page: 99,
      include: ['sections'],
      ...parameters,
    },
  }
  let discussions = paginate(url, options)
  return exhaust(discussions)
}

export function getAllDiscussionEntries (context: CanvasContext, contextID: string, discussionID: string, includeNewEntries: boolean = true): ApiPromise<DiscussionView> {
  const options = {
    params: { include_new_entries: includeNewEntries ? 1 : 0 },
  }
  const url = `${context}/${contextID}/discussion_topics/${discussionID}/view`
  return httpClient().get(url, options)
}

export function getDiscussion (context: CanvasContext, contextID: string, discussionID: string): ApiPromise<Discussion> {
  const url = `${context}/${contextID}/discussion_topics/${discussionID}?include[]=sections`
  return httpClient().get(url)
}

export function createDiscussion (context: CanvasContext, contextID: string, parameters: CreateDiscussionParameters): ApiPromise<Discussion> {
  const url = `${context}/${contextID}/discussion_topics`
  const formdata = discussionFormData(parameters)
  return httpClient().post(url, formdata)
}

export function createEntry (context: CanvasContext, contextID: string, discussionID: string, entryID: string = '', parameters: CreateEntryParameters): ApiPromise<Discussion> {
  const url = entryID ? `${context}/${contextID}/discussion_topics/${discussionID}/entries/${entryID}/replies` : `${context}/${contextID}/discussion_topics/${discussionID}/entries`
  const formdata = discussionFormData(parameters)
  return httpClient().post(url, formdata)
}

export function editEntry (context: CanvasContext, contextID: string, discussionID: string, entryID: string, parameters: CreateEntryParameters): ApiPromise<Discussion> {
  const url = `${context}/${contextID}/discussion_topics/${discussionID}/entries/${entryID}`
  const formdata = discussionFormData(parameters)
  return httpClient().put(url, formdata)
}

export function updateDiscussion (context: CanvasContext, contextID: string, parameters: UpdateDiscussionParameters): ApiPromise<Discussion> {
  const url = `${context}/${contextID}/discussion_topics/${parameters.id}`
  const formdata = discussionFormData(parameters)
  return httpClient().put(url, formdata)
}

export function deleteDiscussionEntry (context: CanvasContext, contextID: string, discussionID: string, entryID: string): ApiPromise<Discussion> {
  const url = `${context}/${contextID}/discussion_topics/${discussionID}/entries/${entryID}`
  return httpClient().delete(url, {})
}

export function deleteDiscussion (context: CanvasContext, contextID: string, discussionID: string): ApiPromise<Discussion> {
  const url = `${context}/${contextID}/discussion_topics/${discussionID}`
  return httpClient().delete(url)
}

export function subscribeDiscussion (context: CanvasContext, contextID: string, discussionID: string, subscribed: boolean): ApiPromise<Discussion> {
  const url = `${context}/${contextID}/discussion_topics/${discussionID}/subscribed`
  return httpClient()[subscribed ? 'put' : 'delete'](url)
}

export function markEntryAsRead (context: CanvasContext, contextID: string, discussionID: string, entryID: string): ApiPromise<null> {
  const url = `${context}/${contextID}/discussion_topics/${discussionID}/entries/${entryID}/read`
  return httpClient().put(url)
}

export function markAllAsRead (context: CanvasContext, contextID: string, discussionID: string): ApiPromise<null> {
  const url = `${context}/${contextID}/discussion_topics/${discussionID}/read_all`
  return httpClient().put(url)
}

export function rateEntry (context: CanvasContext, contextID: string, discussionID: string, entryID: string, rating: number): ApiPromise<null> {
  const url = `${context}/${contextID}/discussion_topics/${discussionID}/entries/${entryID}/rating`
  return httpClient().post(url, { rating })
}

function discussionFormData (parameters: CreateDiscussionParameters | UpdateDiscussionParameters | CreateEntryParameters): FormData {
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
