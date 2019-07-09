//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
