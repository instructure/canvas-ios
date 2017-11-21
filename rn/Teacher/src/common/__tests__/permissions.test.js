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

import Permissions from '../permissions'
import {
  AlertIOS,
  Linking,
} from 'react-native'

test('error messages', () => {
  expect(Permissions.errorMessages()).toEqual({
    microphone: 'You must enable Microphone permissions in Settings to record audio.',
    camera: 'You must enable Camera and Microphone permissions in Settings to use the camera.',
    photos: 'You must enable Photos permissions in Settings.',
  })
})

test('alert links to settings', () => {
  const spy = jest.fn()
  // $FlowFixMe
  Linking.canOpenURL = jest.fn(() => ({ then: (callback) => callback(true) }))
  // $FlowFixMe
  Linking.openURL = spy
  // $FlowFixMe
  AlertIOS.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
  Permissions.alert('microphone')
  expect(spy).toHaveBeenCalledWith('app-settings:')
})

test('alert does not link to settings if cant open url', () => {
  const spy = jest.fn()
  // $FlowFixMe
  Linking.canOpenURL = jest.fn(() => ({ then: (callback) => callback(false) }))
  // $FlowFixMe
  Linking.openURL = spy
  // $FlowFixMe
  AlertIOS.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
  Permissions.alert('microphone')
  expect(spy).not.toHaveBeenCalled()
})
