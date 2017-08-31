//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow

import { ERROR_TITLE, ERROR_MESSAGE, parseErrorMessage } from '../error-handler'
import { Alert } from 'react-native'
import mockStore from '../../../../test/helpers/mockStore'
import { updateStatus } from '../../../utils/online-status'

jest.mock('Alert', () => ({
  alert: jest.fn(),
}))

jest.mock('../../../common/login-verify.js', () => {
  return () => {
    return {
      then: (resolve: Function) => {
        resolve(false)
      },
    }
  }
})

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

  describe('401 errors', () => {
    it('throws up an alert with a custom error message', () => {
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
              status: 401,
            },
          },
        },
      })

      expect(Alert.alert).toHaveBeenCalledWith(ERROR_TITLE, errorMessage)
    })

    it('do nothing because the component handles the error', () => {
      let errorMessage = 'An error message'
      let store = mockStore()
      store.dispatch({
        type: 'test',
        error: true,
        payload: {
          handlesError: true,
          error: {
            response: {
              data: {
                errors: [{
                  message: errorMessage,
                }],
              },
              status: 401,
            },
          },
        },
      })

      expect(Alert.alert).not.toHaveBeenCalledWith(ERROR_TITLE, errorMessage)
    })
  })

  it('doesnt show an alert for api errors when the user is offline', () => {
    updateStatus('none')
    let store = mockStore()
    store.dispatch({
      type: 'test',
      error: true,
      payload: {
        error: {
          message: 'Network Error',
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

  it('should parse axios response errors with error object vs array', () => {
    const response = {
      status: 500,
      data: {
        errors: {
          name: [{
            attribute: 'name',
            message: 'cannot be changed because this assignment is due in a closed grading period',
          }],
          'description': [{ attribute: 'description', message: 'is too long' }],
        },
      },
      headers: { link: null },
    }
    const expected = 'name cannot be changed because this assignment is due in a closed grading period. description is too long'
    const result = parseErrorMessage(response)
    expect(result).toEqual(expected)
  })

  it('should parse axios response errors with error empty object vs array', () => {
    const response = {
      status: 500,
      data: {
        errors: {
          name: [{
          }],
          'description': [{ attribute: 'description', message: 'is too long' }],
        },
      },
      headers: { link: null },
    }
    const expected = ' . description is too long'
    const result = parseErrorMessage(response)
    expect(result).toEqual(expected)
  })

  it('should use default error message if there are no messages', () => {
    const response = {
      status: 500,
      data: {},
      headers: { link: null },
    }
    const expected = ERROR_MESSAGE
    const result = parseErrorMessage(response)
    expect(result).toEqual(expected)
  })

  it('should use default error message if there are no messages round 2', () => {
    const response = {
      status: 500,
      data: {
        errors: {},
      },
      headers: { link: null },
    }
    const expected = ERROR_MESSAGE
    const result = parseErrorMessage(response)
    expect(result).toEqual(expected)
  })

  it('should use default error message if there are no messages round 3', () => {
    const response = {
      status: 500,
      data: {
        errors: {
          'blank error': [],
        },
      },
      headers: { link: null },
    }
    const expected = ERROR_MESSAGE
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
