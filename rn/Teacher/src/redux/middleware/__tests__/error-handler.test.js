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

import { parseErrorMessage, defaultErrorMessage, defaultErrorTitle, resetGlobalErrorAlert } from '../error-handler'
import { Alert } from 'react-native'
import mockStore from '../../../../test/helpers/mockStore'

jest.mock('Alert', () => ({
  alert: jest.fn(),
}))

jest.mock('../../../common/login-verify.js', () => {
  return () => ({
    then: (resolve: Function) => resolve(false),
  })
})

describe('error-handler-middleware', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    resetGlobalErrorAlert()
  })

  it('throws up an alert if the action is not an api error', async () => {
    let message = 'I be an error'
    let store = mockStore()
    store.dispatch({
      type: 'test',
      error: true,
      payload: {
        error: new Error(message),
      },
    })
    await Promise.resolve()
    await Promise.resolve()
    expect(Alert.alert).toHaveBeenCalled()
  })

  it('throws up an alert with a custom error message when the action is an api error and the user is online', async () => {
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

    await Promise.resolve()
    await Promise.resolve()
    expect(Alert.alert).toHaveBeenCalled()
  })

  describe('401 errors', () => {
    it('throws up an alert with a custom error message', async () => {
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

      await Promise.resolve()
      await Promise.resolve()
      expect(Alert.alert).toHaveBeenCalled()
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

      expect(Alert.alert).not.toHaveBeenCalledWith(defaultErrorTitle(), errorMessage)
    })
  })

  it('throws up an alert when the action does not indicate it will handle its own errors', async () => {
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

    await Promise.resolve()
    await Promise.resolve()
    expect(Alert.alert).toHaveBeenCalled()
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

  it('does nothing if action is not an error', () => {
    let store = mockStore()
    store.dispatch({
      type: 'test',
      payload: {},
    })
    expect(Alert.alert).not.toHaveBeenCalled()
  })
})

describe('parse error message', () => {
  it('should parse api response errors', () => {
    const response = {
      status: 500,
      data: { errors: [{ message: 'Internal server error' }] },
      headers: { link: null },
    }
    const expected = 'Internal server error'
    const result = parseErrorMessage(response)
    expect(result).toEqual(expected)
  })

  it('should parse api response errors with error object vs array', () => {
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
    const expected = 'cannot be changed because this assignment is due in a closed grading period. is too long'
    const result = parseErrorMessage(response)
    expect(result).toEqual(expected)
  })

  it('should parse api response errors with error empty object vs array', () => {
    const response = {
      status: 500,
      data: {
        errors: {
          name: [{
          }],
          'description': [{ attribute: 'description', message: 'description is too long' }],
        },
      },
      headers: { link: null },
    }
    const expected = '. description is too long'
    const result = parseErrorMessage(response)
    expect(result).toEqual(expected)
  })

  it('should use default error message if there are no messages', () => {
    const response = {
      status: 500,
      data: {},
      headers: { link: null },
    }
    const result = parseErrorMessage(response)
    expect(result).toEqual(defaultErrorMessage())
  })

  it('should use default error message if there are no messages round 2', () => {
    const response = {
      status: 500,
      data: {
        errors: {},
      },
      headers: { link: null },
    }
    const result = parseErrorMessage(response)
    expect(result).toEqual(defaultErrorMessage())
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
    const result = parseErrorMessage(response)
    expect(result).toEqual(defaultErrorMessage())
  })

  it('should parse string errors', () => {
    const error = 'i am an error'
    const expected = 'i am an error'
    const result = parseErrorMessage(error)
    expect(result).toEqual(expected)
  })

  it('should parse Error types', () => {
    const error = new Error('i am an error')
    const expected = 'i am an error'
    const result = parseErrorMessage(error)
    expect(result).toEqual(expected)
  })

  it('should parse quota errors', () => {
    const error = { response: { data: { message: 'file size exceeds quota' } } }
    const expected = 'file size exceeds quota'
    const result = parseErrorMessage(error)
    expect(result).toEqual(expected)
  })

  it('should look for response errors', () => {
    const error = new Error('i am an error')
    // $FlowFixMe
    error.response = {
      data: { errors: { published: 'You do not have permission' } },
    }
    const result = parseErrorMessage(error)
    expect(result).toBe('You do not have permission')
  })
})
