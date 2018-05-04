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
import { shallow } from 'enzyme'
import React from 'react'
import {
  DeviceEventEmitter,
  NativeModules,
  SafeAreaView,
} from 'react-native'
import Screen from '../Screen'

jest.mock('react-native', () => ({
  DeviceEventEmitter: {
    addListener: jest.fn((key) => key),
    removeSubscription: jest.fn(),
  },
  NativeModules: {
    Helm: {
      setScreenConfig: jest.fn(),
    },
  },
  SafeAreaView: () => 'SafeAreaView',

  // needed by files imported by Screen and other routing files
  Text: {
    propTypes: {},
  },
  StyleSheet: { create: jest.fn() },
}))

describe('Screen component', () => {
  const context = {
    screenInstanceID: 'siid',
  }

  const defaultScreenConfig = {
    backButtonTitle: 'Back',
    navBarStyle: 'light',
    statusBarStyle: 'default',
    showDismissButton: true,
  }

  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('renders nothing until mounted', () => {
    const tree = shallow(<Screen><a/></Screen>, {
      context,
      disableLifecycleMethods: true,
    })
    expect(tree.find('a').exists()).toBe(false)
    expect(tree.type()).toBeNull()
    expect(NativeModules.Helm.setScreenConfig).toHaveBeenCalledWith(
      defaultScreenConfig,
      context.screenInstanceID,
      false
    )
  })

  it('renders non-null after mounting', () => {
    const tree = shallow(<Screen><a/></Screen>, { context })
    expect(tree.find('a').exists()).toBe(true)
    expect(tree.type()).not.toBeNull()
    expect(NativeModules.Helm.setScreenConfig).toHaveBeenCalledWith(
      defaultScreenConfig,
      context.screenInstanceID,
      true
    )
  })

  it('renders null if no children are passed', () => {
    const tree = shallow(<Screen />, { context })
    expect(tree.type()).toBeNull()
  })

  it('renders a SafeAreaView wrapper', () => {
    const tree = shallow(<Screen><a/></Screen>, { context })
    expect(tree.type()).toBe(SafeAreaView)
  })

  it('can disable the SafeAreaView wrapper', () => {
    const tree = shallow(<Screen disableGlobalSafeArea><a/></Screen>, { context })
    expect(tree.type()).toBe('a')
  })

  it('does not talk to helm if no screenInstanceID is in context', () => {
    shallow(<Screen />)
    expect(NativeModules.Helm.setScreenConfig).not.toHaveBeenCalled()
  })

  it('tries to match the statusBarStyle to the navBarStyle', () => {
    shallow(<Screen navBarStyle='dark' />, { context })
    expect(NativeModules.Helm.setScreenConfig).toHaveBeenCalledWith({
      ...defaultScreenConfig,
      navBarStyle: 'dark',
      statusBarStyle: 'light',
    }, context.screenInstanceID, true)
  })

  it('subscribes to device event emitter for bar button callbacks', () => {
    const testID = 'attachments.dismiss-btn'
    const key = `HelmScreen.${context.screenInstanceID}.${testID}`
    shallow(
      <Screen
        leftBarButtons={[ {
          title: 'Done',
          testID,
          style: 'done',
          action: () => {},
        } ]}
      />,
      { context }
    )
    expect(NativeModules.Helm.setScreenConfig).toHaveBeenCalledWith({
      ...defaultScreenConfig,
      leftBarButtons: [ {
        title: 'Done',
        testID,
        style: 'done',
        action: key,
      } ],
    }, context.screenInstanceID, true)
    expect(DeviceEventEmitter.addListener).toHaveBeenCalledWith(
      key,
      expect.any(Function)
    )
  })

  it('replaces subscription on new props', () => {
    const tree = shallow(
      <Screen
        leftBarButtons={[ {
          testID: 'dismiss-btn',
          action: () => {},
        } ]}
      />,
      { context }
    )
    tree.setProps({ leftBarButtons: [ {
      testID: 'dismiss-btn',
      action () {},
    } ] })
    expect(DeviceEventEmitter.removeSubscription).toHaveBeenCalled()
  })

  it('removes subscription on unmount', () => {
    const tree = shallow(
      <Screen
        leftBarButtons={[ {
          title: 'Done',
          testID: 'attachments.dismiss-btn',
          style: 'done',
          action: () => {},
        } ]}
      />,
      { context }
    )
    tree.unmount()
    expect(DeviceEventEmitter.removeSubscription).toHaveBeenCalled()
  })
})
