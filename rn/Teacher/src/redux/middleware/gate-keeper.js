// @flow

import type { MiddlewareAPI } from 'redux'
import { Alert } from 'react-native'
import { HYDRATE_ACTION } from '../hydrate-action'
import logoutAction from '../logout-action'
import { isFSA } from 'flux-standard-action'
import i18n from 'format-message'
import { isOnline } from '../../utils/online-status'

let isLoggedIn = false
let isAlertOpen = false

export function updateAlertState (state: boolean): void {
  isAlertOpen = state
}

const gateKeeperMiddleware: MiddlewareAPI = () => {
  return next => action => {
    if (action.type === HYDRATE_ACTION) {
      isLoggedIn = true
    }

    if (action.type === logoutAction.type) {
      isLoggedIn = false
    }

    let promise = action.payload && action.payload.promise || action.payload
    if (!isOnline() && isFSA(action) && promise instanceof Promise) {
      if (!isAlertOpen) {
        updateAlertState(true)
        Alert.alert(
          i18n('No internet connection'),
          i18n('This action requires an internet connection.'),
          [
            { text: 'Cancel', onPress: () => updateAlertState(false), style: 'cancel' },
          ]
        )
      }
    }

    if (isLoggedIn || action.type === logoutAction.type) {
      next(action)
    }
  }
}

export default gateKeeperMiddleware
