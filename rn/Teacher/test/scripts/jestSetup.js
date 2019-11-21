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

/* @flow */
import 'trace' // long async stack traces
import 'clarify' // remove node noise from stack traces

// import 'react-native-mock/mock'
import { setSession } from '../../src/canvas-api/session'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
Enzyme.configure({ adapter: new Adapter() })

import * as template from '../../src/__templates__'

import i18n from 'format-message'
import setupI18n from '../../i18n/setup'
import { shouldTrackAsyncActions } from '../../src/redux/middleware/redux-promise'
import ExperimentalFeature from '../../src/common/ExperimentalFeature'

setupI18n('en')

// Make most date rendering use a consistent timeZone.
const formats = i18n.setup().formats
for (const key of Object.keys(formats.date)) {
  formats.date[key].timeZone = 'America/Denver'
}
for (const key of Object.keys(formats.time)) {
  formats.time[key].timeZone = 'America/Denver'
}

shouldTrackAsyncActions(false)
setSession(template.session())

// import mockAsyncStorage from '@react-native-community/async-storage/jest/async-storage-mock'
jest.mock('@react-native-community/async-storage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  getAllKeys: jest.fn(),
  multiRemove: jest.fn(),
}))

jest.mock('react-native-document-picker', () => ({
  DocumentPicker: {
    show: jest.fn((options, callback) => callback({
      uri: 'file://path/to/somewhere/on/disk.pdf',
      fileName: 'disk.pdf',
      fileSize: 100,
    })),
  },
  DocumentPickerUtil: {
    allFiles: jest.fn(() => 'content'),
    images: jest.fn(() => 'image'),
    video: jest.fn(() => 'video'),
    audio: jest.fn(() => 'audio'),
  },
}))

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
  changeUser: jest.fn(),
  stopActing: jest.fn(),
  logout: jest.fn(),
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
  addObserver: jest.fn(),
  postNotification: jest.fn(),
}

NativeModules.TabBarItemCounts = {
  updateUnreadMessageCount: jest.fn(),
  updateTodoListCount: jest.fn(),
}

NativeModules.SettingsManager = {
  settings: {
    AppleLocale: 'en',
  },
  setValues: jest.fn(),
}

NativeModules.Helm = {
  setScreenConfig: jest.fn(),
  openInSafariViewController: jest.fn(() => Promise.resolve()),
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
  stopRefreshing: jest.fn(),
}

NativeModules.WebViewHacker = {
  removeInputAccessoryView: jest.fn(),
  setKeyboardDisplayRequiresUserAction: jest.fn(),
}

NativeModules.APIBridge = {
  requestCompleted: jest.fn(),
}

NativeModules.AppStoreReview = {
  handleSuccessfulSubmit: jest.fn(),
  handleNavigateToAssignment: jest.fn(),
  handleNavigateFromAssignment: jest.fn(),
  handleUserFeedbackOnDashboard: jest.fn(),
  setState: jest.fn(),
}

NativeModules.CanvasAnalytics = {
  logEvent: jest.fn(),
}

NativeModules.QLPreviewManager = {
  previewFile: jest.fn(),
}

NativeModules.LTITools = {
  launchExternalTool: jest.fn(),
}

NativeModules.SiriShortcutManager = {
  donateSiriShortcut: jest.fn(),
}

jest.mock('NativeEventEmitter')

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

NativeModules.ModuleItemsProgress = {
  viewedDiscussion: jest.fn(),
  viewedPage: jest.fn(),
  contributedDiscussion: jest.fn(),
}

jest.mock('../../src/common/components/AuthenticatedWebView', () => 'AuthenticatedWebView')
jest.mock('../../src/common/components/A11yGroup', () => 'A11yGroup')
jest.mock('react-native-device-info', () => {
  return {
    getVersion: () => {
      return '1.0'
    },
  }
})

jest.mock('../../src/canvas-api/httpClient')

// makes tree.find('FlatList').dive() useful
jest.mock('FlatList', () => {
  const React = require('React')
  return class FlatList extends React.Component {
    render () {
      const props = this.props
      const empty = (
        typeof props.ListEmptyComponent === 'function' && <props.ListEmptyComponent /> ||
        props.ListEmptyComponent || null
      )
      return (
        <list>
          {props.data && props.data.length > 0
            ? props.data.map((item, index) =>
              <item key={item.key || props.keyExtractor(item, index)}>
                {props.renderItem({ item, index })}
              </item>
            )
            : empty
          }
        </list>
      )
    }
  }
})

// makes tree.find('KeyboardAwareFlatList').dive() useful
jest.mock('react-native-keyboard-aware-scroll-view/lib/KeyboardAwareFlatList', () => {
  const React = require('React')
  return class KeyboardAwareFlatList extends React.Component {
    render () {
      const props = this.props
      const empty = (
        typeof props.ListEmptyComponent === 'function' && <props.ListEmptyComponent /> ||
        props.ListEmptyComponent || null
      )
      return (
        <list>
          {props.data && props.data.length > 0
            ? props.data.map((item, index) =>
              <item key={item.key || props.keyExtractor(item, index)}>
                {props.renderItem({ item, index })}
              </item>
            )
            : empty
          }
        </list>
      )
    }
  }
})

// makes tree.find('SectionList').dive() useful
jest.mock('SectionList', () => {
  const React = require('React')
  return class SectionList extends React.Component {
    render () {
      const props = this.props
      const empty = (
        typeof props.ListEmptyComponent === 'function' && <props.ListEmptyComponent /> ||
        props.ListEmptyComponent || null
      )
      return (
        <list>
          {props.sections && props.sections.length > 0
            ? props.sections.map((section, index) =>
              <section key={section.key || index}>
                {props.renderSectionHeader && props.renderSectionHeader({ section })}
                {section.data.map((item, index) =>
                  <item key={item.key || (section.keyExtractor || props.keyExtractor)(item, index)}>
                    {(section.renderItem || props.renderItem)({ item, index })}
                  </item>
                )}
              </section>
            )
            : empty
          }
        </list>
      )
    }
  }
})

// makes tree.find('KeyboardAwareScrollView').getELement().ref possible
jest.mock('react-native-keyboard-aware-scroll-view/lib/KeyboardAwareScrollView', () => 'KeyboardAwareScrollView')

jest.mock('I18nManager', () => ({
  isRTL: false,
}))

jest.mock('Settings', () => {
  let settings = {}
  return {
    get (key) {
      return settings[key]
    },
    set (obj) {
      settings = {
        ...settings,
        ...obj,
      }
    },
  }
})

ExperimentalFeature.allEnabled = true
