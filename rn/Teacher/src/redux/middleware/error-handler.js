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

import { Alert, NetInfo } from 'react-native'
import type { MiddlewareAPI } from 'redux'
import i18n from 'format-message'
import loginVerify from '../../common/login-verify'

export function alertError (error: any, alertTitle?: string, callback?: Function): void {
  const title = alertTitle || defaultErrorTitle()
  const message = parseErrorMessage(error)
  let buttons = [{ text: i18n('Dismiss'), onPress: () => { if (callback) callback() } }]
  Alert.alert(title, message, buttons)
}

export function defaultErrorTitle (): string {
  return i18n('Unexpected Error')
}

export function defaultErrorMessage (): string {
  return i18n('There was an unexpected error. Please try again.')
}

let showingGlobalErrorAlert = false
const showGlobalErrorAlertIfNecessary = async (error: any) => {
  if (showingGlobalErrorAlert) return
  showingGlobalErrorAlert = true
  if (error.response != null) {
    error = error.response
  }

  let alertTitle

  // https://github.com/facebook/react-native/issues/8615
  NetInfo.isConnected.fetch().then(() => {
    NetInfo.isConnected.fetch().then(isConnected => {
      if (!isConnected) {
        error = Error(i18n('It looks like your internet connection is offline. Reconnect to the internet and try again.'))
        alertTitle = i18n('Internet Connection Offline')
      }

      alertError(error, alertTitle, () => {
        resetGlobalErrorAlert()
      })
    })
  })
}

export function resetGlobalErrorAlert () {
  showingGlobalErrorAlert = false
}

const errorHandlerMiddleware: MiddlewareAPI = () => {
  return next => action => {
    if (action.error) {
      let error = action.payload.error
      if (error && error.response && error.response.status === 401) {
        loginVerify().then((invalid) => {
          if (!invalid) {
            if (action.payload.handlesError) return next(action)
            showGlobalErrorAlertIfNecessary(error)
          }
          next(action)
        })
        return // Bail out of this because of the promise. Next will be called after the promise has finished
      } else {
        if (action.payload.handlesError) return next(action)
        showGlobalErrorAlertIfNecessary(error)
      }
    }
    next(action)
  }
}

export default errorHandlerMiddleware

export function parseErrorMessage (error: any): string {
  if (error && error.response) error = error.response

  if (typeof error === 'string') {
    return error
  }

  if (error && error.data && error.data.message) {
    return error.data.message
  } else if (error && error.data && error.data.errors && error.data.errors.length > 0) {
    return error.data.errors
      .map(error => error.message)
      .map(message => message.replace(/\.+$/, ''))
      .join('. ')
  } else if (error && error.data && error.data.errors instanceof Object && Object.keys(error.data.errors).length > 0) {
    let data = error.data.errors
    let result = Object.keys(data)
      .map((key, index) => {
        let err = data[key]
        if (Array.isArray(err) && err.length > 0) err = err[0]
        if (typeof err === 'string') return err
        return err && err.message || ''
      })
      .join('. ')

    if (result.trim()) {
      return result
    }
  }

  if (error instanceof Error) {
    return error.message
  }

  return defaultErrorMessage()
}
