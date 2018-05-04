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
import APIBridge, { handleAPIBridgeRequest } from '../APIBridge'
import { NativeModules } from 'react-native'

jest.mock('../', () => ({
  mockAPI: jest.fn(() => Promise.resolve({ data: { key: 'value' } })),
}))

describe('APIBridge', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('makes an api request and sends it back to native land', async () => {
    const body = {
      requestID: 'request',
      name: 'mockAPI',
      args: [],
    }
    await handleAPIBridgeRequest(body)
    expect(NativeModules.APIBridge.requestCompleted).toHaveBeenCalledWith('request', { key: 'value' }, null)
  })

  it('bails if the api does not exist', async () => {
    const body = {
      requestID: 'request',
      name: 'shouldFail',
    }
    try {
      await handleAPIBridgeRequest(body)
    } catch (e) {
      expect(e).toBeDefined()
    }
  })

  it('throws an error if no arguments are passed in', async () => {
    const body = {
      requestID: 'request',
      name: 'mockAPI',
    }
    await handleAPIBridgeRequest(body)
    expect(NativeModules.APIBridge.requestCompleted).toHaveBeenCalledWith('request', null, 'Request could not be completed.')
  })

  it('not sure how to test this but it should not blow up', async () => {
    APIBridge()
  })
})
