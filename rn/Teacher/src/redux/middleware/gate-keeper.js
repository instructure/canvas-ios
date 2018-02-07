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
      return
    }

    if (isLoggedIn || action.type === logoutAction.type) {
      next(action)
    }
  }
}

export default gateKeeperMiddleware
