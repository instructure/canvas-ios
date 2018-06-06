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
const appKey = 'CANVAS_STUDENT_IOS'

export function fetchPandataToken (userID: string): ApiPromise<any> {
  const options = { app_key: appKey }
  return httpClient().post(`/users/${userID}/pandata_token`, options)
}

export async function sendEvents (eventsAsJsonString: string, pandataToken: string): ApiPromise<any> {
  let events = JSON.parse(eventsAsJsonString)
  let mappedEvents = events.map((e) => {
    return {
      timestamp: e.timestamp,
      appTag: appKey,
      eventType: 'page_view',
      userID: e.userID,
      properties: { page_name: e.eventName, url: e.attributes.url, interaction_seconds: e.eventDuration } }
  })

  const options = { events: mappedEvents }
  const config = {
    baseURL: 'https://cbbsk4vb5k.execute-api.us-east-1.amazonaws.com',
    headers: {
      'Authorization': `Bearer ${pandataToken}`,
    },
    excludeVersion: true,
  }
  return httpClient().post('/prod/pandata-event', options, config)
}

