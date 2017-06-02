// @flow
import { AsyncStorage } from 'react-native'
import { getSession } from '../../api/session'
import type { MiddlewareAPI } from 'redux'
import hydrate from '../hydrate-action'

const STORE_VERSION = '1'

function storeName (session: Session): string {
  return `redux.state.${session.user.id}.${STORE_VERSION}`
}

async function removeOldStates (session: Session) {
  await AsyncStorage.multiRemove(
    (await AsyncStorage.getAllKeys())
      .filter(k => k.startsWith(`redux.state.${session.user.id}`))
  )
}

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

  await AsyncStorage.setItem(storeName(session), JSON.stringify(cache))
}

export async function hydrateStoreFromPersistedState (store: any): any {
  let session = getSession()
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
