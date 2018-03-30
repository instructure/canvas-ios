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
import { getSessionUnsafe } from '../session'

export function refreshGroupFavorites (userID: string): ApiPromise<EntityRefs> {
  const url = `users/${userID}/custom_data/favorites/groups`
  const options = {
    params: {
      ns: constructNamespace(),
    },
  }
  return httpClient().get(url, options)
}

export function updateGroupFavorites (userID: string, favorites: string[]): ApiPromise<EntityRefs> {
  const url = `users/${userID}/custom_data/favorites/groups`
  const options = {
    ns: constructNamespace(),
    data: favorites,
  }
  return httpClient().put(url, options)
}

export function constructNamespace (): string {
  let session = getSessionUnsafe()
  if (!session) return ''

  let url: string = session.baseURL || ''
  let host
  if (url.indexOf('://') > -1) {
    host = url.split('/')[2]
  } else {
    host = url.split('/')[0]
  }

  let domainParts = host.split('.')

  if (domainParts.length === 0) return ''
  if (!domainParts[0]) return ''

  return `com.${domainParts[0]}.canvas-app`
}
