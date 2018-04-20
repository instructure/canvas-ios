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
import { AsyncStorage } from 'react-native'
import { getSessionUnsafe } from '../../canvas-api'
import type { MiddlewareAPI } from 'redux'
import hydrate from '../hydrate-action'

const STORE_VERSION = '14'

function storeName (session: Session): string {
  return `redux.state.${session.baseURL}.${session.user.id}.${STORE_VERSION}`
}

async function removeOldStates (session: Session) {
  await AsyncStorage.multiRemove(
    (await AsyncStorage.getAllKeys()).filter(k =>
      k.startsWith('redux.state.') &&
      !k.endsWith(`.${STORE_VERSION}`)
    )
  )
}

async function persistState (store) {
  let state = store.getState()
  // we don't need async actions in the cache
  // it also causes errors because we keep track of errors
  // which contain circular references that cannot be stringified
  state = {
    ...state,
    asyncActions: {},
  }

  let session = getSessionUnsafe()
  if (!session) return

  let expires = new Date()
  expires.setDate(expires.getDate() + 1)
  let cache = {
    expires: expires,
    state,
  }

  await AsyncStorage.setItem(storeName(session), JSON.stringify(cache))
}

export async function hydrateStoreFromPersistedState (store: any): any {
  let session = getSessionUnsafe()
  if (session) {
    let cachedState = await AsyncStorage.getItem(storeName(session))
    if (!cachedState) {
      await removeOldStates(session)
    }
    let appState
    try {
      appState = JSON.parse(cachedState)
    } catch (err) {}
    store.dispatch(hydrate(appState))
  }
}

export async function purgeUserStoreData () {
  let session = getSessionUnsafe()
  return session && AsyncStorage.removeItem(storeName(session))
}

const createPersistMiddleware = (timeoutWait: number): MiddlewareAPI => {
  return (store) => {
    let timeout
    return next => async (action) => {
      next(action)

      clearTimeout(timeout)
      timeout = setTimeout(() => persistState(store), timeoutWait)
    }
  }
}

export default createPersistMiddleware
