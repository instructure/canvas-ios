//
// Copyright (C) 2018-present Instructure, Inc.
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
const appKey = 'CANVAS_STUDENT_IOS'

export function fetchPandataToken (userID: string): ApiPromise<any> {
  const options = { app_key: appKey }
  return httpClient.post(`/users/self/pandata_events_token`, options)
}

export async function sendEvents (eventsAsJsonString: string, endpointInfo: {[string]: any}): ApiPromise<any> {
  let authToken = endpointInfo.auth_token
  let propsToken = endpointInfo.props_token
  let url = endpointInfo.url

  let events = JSON.parse(eventsAsJsonString)
  let mappedEvents = events.map((e) => {
    let attributes = e.attributes || {}
    return {
      timestamp: e.timestamp,
      appTag: appKey,
      eventType: 'page_view',
      properties: {
        page_name: e.eventName,
        url: attributes.url,
        interaction_seconds: e.eventDuration,
        domain: attributes.domain,
        context_type: attributes.context_type,
        context_id: attributes.context_id,
        app_name: attributes.app_name,
        real_user_id: attributes.real_user_id,
        user_id: attributes.user_id,
        session_id: attributes.session_id,
        agent: attributes.agent,
      },
      signedProperties: propsToken,
    }
  })

  const options = { events: mappedEvents }
  const config = {
    baseURL: url,
    headers: {
      'Authorization': `Bearer ${authToken}`,
    },
    excludeVersion: true,
  }
  return httpClient.post('', options, config)
}

