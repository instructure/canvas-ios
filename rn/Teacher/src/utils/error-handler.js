// @flow

import { Alert } from 'react-native'
import type { MiddlewareAPI } from 'redux'
import i18n from 'format-message'

export const ERROR_TITLE = i18n({
  default: 'Unexpected Error',
  description: 'The generic title of the generic error message',
})
export const ERROR_MESSAGE = i18n({
  default: 'There was an unexpected error. Please close this alert and try again.',
  description: 'A generic error message',
})

const errorHandlerMiddleware: MiddlewareAPI = () => {
  return next => action => {
    if (action.error) {
      // should only continue if:
      // 1. error is not an api response error
      // 2. error is an api response error and the status code is 500 or above
      // 3. the action hasn't indicated it will handle the error itself
      let error = action.payload.error || action.payload
      let isApiError = error.data && error.status
      if (!isApiError || error.status >= 500 || !action.payload.handlesError) {
        let errorMessage = error.message || ERROR_MESSAGE
        if (error.data && error.data.errors && error.data.errors.length > 0) {
          errorMessage = error.data.errors[0].message
        }
        Alert.alert(ERROR_TITLE, errorMessage)
      }
    }
    next(action)
  }
}

export default errorHandlerMiddleware
