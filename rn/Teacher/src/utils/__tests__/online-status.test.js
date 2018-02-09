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

/* eslint-disable flowtype/require-valid-file-annotation */

import * as onlineStatus from '../online-status'
import { NetInfo } from 'react-native'

beforeEach(() => jest.resetAllMocks())
afterAll(() => onlineStatus.updateStatus('wifi'))

jest.mock('NetInfo', () => ({
  fetch: jest.fn(),
  addEventListener: jest.fn(),
}))

test('updateStatus', () => {
  onlineStatus.updateStatus('wifi')
  expect(onlineStatus.getOnlineStatus()).toEqual('wifi')
  onlineStatus.updateStatus('mobile')
  expect(onlineStatus.getOnlineStatus()).toEqual('mobile')
})

test('isOnline', () => {
  onlineStatus.updateStatus('wifi')
  expect(onlineStatus.isOnline()).toBeTruthy()
  onlineStatus.updateStatus('none')
  expect(onlineStatus.isOnline()).toBeFalsy()
})

test('refreshOnlineStatus', async () => {
  NetInfo.fetch.mockReturnValueOnce(Promise.resolve('LTE'))

  await onlineStatus.refreshOnlineStatus()
  expect(onlineStatus.getOnlineStatus()).toEqual('LTE')
})

test('updateAppState', async () => {
  NetInfo.fetch.mockReturnValueOnce(Promise.resolve('LTE'))

  await onlineStatus.updateAppState('background')
  expect(NetInfo.fetch).not.toHaveBeenCalled()

  await onlineStatus.updateAppState('active')
  expect(NetInfo.fetch).toHaveBeenCalled()
  expect(onlineStatus.getOnlineStatus()).toEqual('LTE')
})
