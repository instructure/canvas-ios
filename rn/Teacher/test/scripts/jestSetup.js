/* @flow */
import setupI18n from '../../i18n/setup'
setupI18n('en')

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

NativeModules.AudioRecorderManager = {
  checkAuthorizationStatus: jest.fn(),
  prepareRecordingAtPath: jest.fn(),
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

jest.mock('AccessibilityInfo', () => ({
  setAccessibilityFocus: jest.fn(),
}))

// Fixes network calls in tests env.
global.XMLHttpRequest = require('xhr2').XMLHttpRequest
import './../../src/common/global-style'

jest.mock('../../src/common/components/AuthenticatedWebView.js', () => 'AuthenticatedWebView')
