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
