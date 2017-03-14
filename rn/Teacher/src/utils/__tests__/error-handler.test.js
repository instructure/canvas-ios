// @flow

import errorHandlerMiddleware, { ERROR_TITLE, ERROR_MESSAGE } from '../error-handler'
import configureMockStore from 'redux-mock-store'
import { Alert } from 'react-native'

let mockStore = configureMockStore([errorHandlerMiddleware])

jest.mock('react-native', () => ({
  Alert: {
    alert: jest.fn(),
  },
}))

describe('error-handler-middleware', () => {
  beforeEach(() => {
    jest.resetAllMocks()
  })

  it('throws up an alert if the action is not an api error', () => {
    let message = 'I be an error'
    let store = mockStore()
    store.dispatch({
      type: 'test',
      error: true,
      payload: {
        error: new Error(message),
        handlesError: true,
      },
    })
    expect(Alert.alert).toHaveBeenCalledWith(ERROR_TITLE, message)
  })

  it('throws up an alert with a custom error message when the action is an api error', () => {
    let errorMessage = 'An error message'
    let store = mockStore()
    store.dispatch({
      type: 'test',
      error: true,
      payload: {
        error: {
          data: {
            errors: [{
              message: errorMessage,
            }],
          },
          status: 500,
        },
      },
    })

    expect(Alert.alert).toHaveBeenCalledWith(ERROR_TITLE, errorMessage)
  })

  it('throws up an alert when the action does not indicate it will handle its own errors', () => {
    let store = mockStore()
    store.dispatch({
      type: 'test',
      error: true,
      payload: {
        error: {
          data: {},
          status: 400,
        },
      },
    })

    expect(Alert.alert).toHaveBeenCalledWith(ERROR_TITLE, ERROR_MESSAGE)
  })

  it('does not throw up an alert when the action indicates it will handle its own errors', () => {
    let store = mockStore()
    store.dispatch({
      type: 'test',
      error: true,
      payload: {
        error: {
          data: {},
          status: 400,
        },
        handlesError: true,
      },
    })

    expect(Alert.alert).not.toHaveBeenCalled()
  })
})

