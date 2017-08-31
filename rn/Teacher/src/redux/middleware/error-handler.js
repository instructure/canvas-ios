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

import { Alert } from 'react-native'
import type { MiddlewareAPI } from 'redux'
import i18n from 'format-message'
import loginVerify from '../../common/login-verify'
export const ERROR_TITLE: string = i18n('Unexpected Error')
export const ERROR_MESSAGE: string = i18n('There was an unexpected error. Please try again.')

const showGlobalErrorAlertIfNecessary = (error: any) => {
  // should only continue if:
  // 1. error is not an api response error
  // 2. error is an api response error and the status code is 500 or above and the user is online
  let isOfflineError = error.message === 'Network Error'
  if (error.response != null) {
    error = error.response
  }
  if (!isOfflineError) {
    let errorMessage = parseErrorMessage(error)
    Alert.alert(ERROR_TITLE, errorMessage)
  }
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
  if (error instanceof Error) {
    return error.message
  }

  if (error && error.data && error.data.errors && error.data.errors.length > 0) {
    return error.data.errors
        .map(error => error.message)
        .map(message => message.replace(/\.+$/, ''))
        .join('. ')
  } else if (error && error.data && error.data.errors instanceof Object && Object.keys(error.data.errors).length > 0) {
    let data = error.data.errors
    let result = Object.keys(data)
      .map((key, index) => data[key])
      .map(obj => obj.length > 0 ? obj[0] : {})
      .map(obj => `${obj.attribute || ''} ${obj.message || ''}`)
      .join('. ')

    if (result.trim()) {
      return result
    }
  }

  return ERROR_MESSAGE
}
