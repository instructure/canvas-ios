//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
