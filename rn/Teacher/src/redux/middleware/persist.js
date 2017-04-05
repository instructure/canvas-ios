// @flow
import { AsyncStorage } from 'react-native'
import { getSession } from '../../api/session'
import type { MiddlewareAPI } from 'redux'

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
