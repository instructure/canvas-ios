/* @flow */
const { NativeModules } = require('react-native')

require.requireActual('View').displayName = 'View'
require.requireActual('Text').displayName = 'Text'
require.requireActual('Image').displayName = 'Image'
require.requireActual('TextInput').displayName = 'TextInput'
require.requireActual('ActivityIndicator').displayName = 'ActivityIndicator'
require.requireActual('TouchableOpacity').displayName = 'TouchableOpacity'

NativeModules.NativeAccessibility = {
  focusElement: jest.fn(),
}

NativeModules.NativeLogin = {
  logout: jest.fn(),
}

NativeModules.PushNotifications = {
  requestPermissions: jest.fn(),
  scheduleLocalNotification: jest.fn(),
}

NativeModules.HapticFeedback = {
  prepare: jest.fn(),
  generate: jest.fn(),
}

NativeModules.RNFSManager = {
  RNFSFileTypeRegular: 'regular',
  RNFSFileTypeDirectory: 'directory',
}

jest.mock('NetInfo', () => ({
  addEventListener: jest.fn(),
  isConnected: {
    addEventListener: jest.fn(),
    fetch: () => Promise.resolve(true),
  },
}))

jest.mock('Animated', () => {
  const ActualAnimated = require.requireActual('Animated')
  return {
    ...ActualAnimated,
    timing: (value, config) => {
      return {
        start: (callback) => {
          callback && callback()
        },
      }
    },
  }
})

jest.mock('PickerIOS', () => {
  const RealComponent = require.requireActual('PickerIOS')
  const React = require('React')
  const PickerIOS = class extends RealComponent {
    render () {
      return React.createElement('PickerIOS', this.props, this.props.children)
    }
  }
  PickerIOS.Item = props => React.createElement('Item', props, props.children)
  PickerIOS.propTypes = RealComponent.propTypes
  return PickerIOS
})

// Fixes network calls in tests env.
global.XMLHttpRequest = require('xhr2').XMLHttpRequest
import './../../src/common/global-style'

jest.mock('../../src/common/components/AuthenticatedWebView.js', () => 'AuthenticatedWebView')

jest.mock('../../src/api/canvas-api', () => ({
  getAuthenticatedSessionURL: jest.fn((url) => {
    return new Promise((resolve, reject) => {
      process.nextTick(() => {
        resolve({
          data: {
            session_url: url,
          },
        })
      })
    })
  }),
}))

global.V02 = true
global.V03 = true
global.V04 = true
global.V05 = true
global.V06 = true
global.V07 = true
