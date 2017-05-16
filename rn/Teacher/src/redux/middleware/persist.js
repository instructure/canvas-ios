// @flow
import { AsyncStorage } from 'react-native'
import { getSession } from '../../api/session'
import type { MiddlewareAPI } from 'redux'
import hydrate from '../hydrate-action'

async function persistState (store) {
  let state = store.getState()
  let session = getSession()
  if (!session) return

  let expires = new Date()
  expires.setDate(expires.getDate() + 1)
  let cache = {
    expires: expires,
    state,
  }

  await AsyncStorage.setItem(`redux.state.${session.user.id}`, JSON.stringify(cache))
}

export async function hydrateStoreFromPersistedState (store: any): any {
  let session = getSession()
  if (session) {
    let cachedState = await AsyncStorage.getItem(`redux.state.${session.user.id}`)
    let appState
    try {
      appState = JSON.parse(cachedState)
    } catch (err) {}
    store.dispatch(hydrate(appState))
  }
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
