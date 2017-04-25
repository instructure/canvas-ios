// @flow

import { Alert } from 'react-native'
import type { MiddlewareAPI } from 'redux'
import i18n from 'format-message'

export const ERROR_TITLE: string = i18n({
  default: 'Unexpected Error',
  description: 'The generic title of the generic error message',
})
export const ERROR_MESSAGE: string = i18n({
  default: 'There was an unexpected error. Please try again.',
  description: 'A generic error message',
})

const errorHandlerMiddleware: MiddlewareAPI = () => {
  return next => action => {
    if (action.error) {
      if (action.payload.handlesError) return next(action)

      // should only continue if:
      // 1. error is not an api response error
      // 2. error is an api response error and the status code is 500 or above and the user is online
      let error = action.payload.error
      let isOfflineError = error.message === 'Offline Error'
      if (error.response != null) {
        error = error.response
      }
      if (!isOfflineError) {
        let errorMessage = parseErrorMessage(error)
        Alert.alert(ERROR_TITLE, errorMessage)
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

  if (error.data && error.data.errors && error.data.errors.length > 0) {
    return error.data.errors
        .map(error => error.message)
        .map(message => message.replace(/\.+$/, ''))
        .join('. ')
  } else if (error.data.errors instanceof Object && Object.keys(error.data.errors).length > 0) {
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
