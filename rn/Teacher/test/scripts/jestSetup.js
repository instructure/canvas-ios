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

/* @flow */
import 'trace' // long async stack traces
import 'clarify' // remove node noise from stack traces

// import 'react-native-mock/mock'
import { setSession } from '../../src/canvas-api/session'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
Enzyme.configure({ adapter: new Adapter() })

import * as template from '../../src/__templates__'

import setupI18n from '../../i18n/setup'
import { shouldTrackAsyncActions } from '../../src/redux/middleware/redux-promise'
setupI18n('en')
shouldTrackAsyncActions(false)
setSession(template.session())

const { NativeModules } = require('react-native')

require.requireActual('View').displayName = 'View'
require.requireActual('Text').displayName = 'Text'
require.requireActual('Image').displayName = 'Image'
require.requireActual('TextInput').displayName = 'TextInput'
require.requireActual('ActivityIndicator').displayName = 'ActivityIndicator'
require.requireActual('TouchableOpacity').displayName = 'TouchableOpacity'

jest.mock('../../src/canvas-api')
global.fetch = require('jest-fetch-mock')

global.requestIdleCallback = jest.fn(cb => cb())

NativeModules.NativeAccessibility = {
  focusElement: jest.fn(),
  refresh: jest.fn(),
}

NativeModules.NativeLogin = {
  logout: jest.fn(),
  switchUser: jest.fn(),
}

NativeModules.WindowTraitsManager = {
  currentWindowTraits: jest.fn(),
}

NativeModules.PushNotifications = {
  requestPermissions: jest.fn(),
  scheduleLocalNotification: jest.fn(),
}

NativeModules.CoreDataSync = {
  syncAction: jest.fn(() => Promise.resolve()),
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

NativeModules.RNSound = {
  isAudio: jest.fn(),
  isWindows: jest.fn(),
}

NativeModules.NativeNotificationCenter = {
  postAsyncActionNotification: jest.fn(),
}

NativeModules.TabBarItemCounts = {
  updateUnreadMessageCount: jest.fn(),
  updateTodoListCount: jest.fn(),
}

NativeModules.SettingsManager = {
  settings: {
    AppleLocale: 'en',
  },
}

NativeModules.Helm = {
  setScreenConfig: jest.fn(),
  pushFrom: jest.fn(() => Promise.resolve()),
  popFrom: jest.fn(() => Promise.resolve()),
  present: jest.fn(() => Promise.resolve()),
  dismiss: jest.fn(() => Promise.resolve()),
  dismissAllModals: jest.fn(() => Promise.resolve()),
  traitCollection: jest.fn(),
}

NativeModules.TabBarBadgeCounts = {
  updateUnreadMessageCount: jest.fn(),
  updateTodoListCount: jest.fn(),
}

NativeModules.CanvasWebViewManager = {
  evaluateJavaScript: jest.fn(() => Promise.resolve()),
}

NativeModules.WebViewHacker = {
  removeInputAccessoryView: jest.fn(),
  setKeyboardDisplayRequiresUserAction: jest.fn(),
}

NativeModules.APIBridge = {
  requestCompleted: jest.fn(),
}

jest.mock('NativeEventEmitter')

jest.mock('NetInfo', () => ({
  fetch: jest.fn(() => Promise.resolve('wifi')),
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
    loop: (value, config) => {
      return {
        start: (callback) => {
          callback && callback()
        },
      }
    },
    sequence: (value, config) => {
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
  announceForAccessibility: jest.fn(),
}))

jest.mock('LayoutAnimation', () => {
  const ActualLayoutAnimation = require.requireActual('LayoutAnimation')
  return {
    ...ActualLayoutAnimation,
    easeInEaseOut: jest.fn(),
    configureNext: jest.fn(),
  }
})

jest.mock('Linking', () => ({
  canOpenURL: jest.fn(() => Promise.resolve(true)),
  openURL: jest.fn(),
}))

jest.mock('AppState', () => ({
  currentState: 'active',
  addEventListener: jest.fn(),
  removeEventListener: jest.fn(),
}))

NativeModules.CameraManager = {
  Aspect: {
    fill: 'fill',
  },
  Type: {
    back: 'back',
  },
  Orientation: {
    auto: 'auto',
  },
  CaptureMode: {
    still: 'still',
  },
  CaptureTarget: {
    cameraRoll: 'cameraRoll',
  },
  CaptureQuality: {
    high: 'high',
  },
  FlashMode: {
    off: 'off',
  },
  TorchMode: {
    off: 'off',
  },
  BarCodeType: [],
}

NativeModules.NativeFileSystem = {
  pathForResource: jest.fn(() => Promise.resolve('/')),
  convertToJPEG: jest.fn(() => Promise.resolve('/image.jpg')),
}

import './../../src/common/global-style'

jest.mock('../../src/common/components/AuthenticatedWebView.js', () => 'AuthenticatedWebView')
jest.mock('react-native-device-info', () => {
  return {
    getVersion: () => {
      return '1.0'
    },
  }
})

jest.mock('../../src/canvas-api/httpClient')
