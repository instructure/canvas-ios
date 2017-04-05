// @flow

import { ERROR_TITLE, ERROR_MESSAGE, parseErrorMessage } from '../error-handler'
import { Alert } from 'react-native'
import mockStore from '../../../../test/helpers/mockStore'
import { updateStatus } from '../../../utils/online-status'

jest.mock('Alert', () => ({
  alert: jest.fn(),
}))

describe('error-handler-middleware', () => {
  beforeEach(() => {
    jest.resetAllMocks()
    updateStatus('wifi')
  })

  it('throws up an alert if the action is not an api error', () => {
    let message = 'I be an error'
    let store = mockStore()
    store.dispatch({
      type: 'test',
      error: true,
      payload: {
        error: new Error(message),
      },
    })
    expect(Alert.alert).toHaveBeenCalledWith(ERROR_TITLE, message)
  })

  it('throws up an alert with a custom error message when the action is an api error and the user is online', () => {
    let errorMessage = 'An error message'
    let store = mockStore()
    store.dispatch({
      type: 'test',
      error: true,
      payload: {
        error: {
          response: {
            data: {
              errors: [{
                message: errorMessage,
              }],
            },
            status: 500,
          },
        },
      },
    })

    expect(Alert.alert).toHaveBeenCalledWith(ERROR_TITLE, errorMessage)
  })

  it('doesnt show an alert for api errors when the user is offline', () => {
    updateStatus('none')
    let store = mockStore()
    store.dispatch({
      type: 'test',
      error: true,
      payload: {
        error: {
          response: {
            data: {
              errors: [{
                message: 'Error',
              }],
            },
            status: 500,
          },
        },
      },
    })

    expect(Alert.alert).not.toHaveBeenCalled()
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
          response: {
            data: {},
            status: 400,
          },
        },
        handlesError: true,
      },
    })

    expect(Alert.alert).not.toHaveBeenCalled()
  })
})

describe('parse error message', () => {
  it('should parse axios response errors', () => {
    const response = {
      status: 500,
      data: { errors: [{ message: 'Internal server error' }] },
      headers: { link: null },
    }
    const expected = 'Internal server error'

    const result = parseErrorMessage(response)

    expect(result).toEqual(expected)
  })

  it('should use status code as error message if there are no messages', () => {
    const response = {
      status: 500,
      data: {},
      headers: { link: null },
    }
    const expected = 'An error occurred (code: 500)'

    const result = parseErrorMessage(response)

    expect(result).toEqual(expected)
  })

  it('should parse Error types', () => {
    const error = new Error('i am an error')
    const expected = 'i am an error'

    const result = parseErrorMessage(error)

    expect(result).toEqual(expected)
  })
})
