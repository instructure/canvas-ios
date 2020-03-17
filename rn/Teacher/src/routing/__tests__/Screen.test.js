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
  I18nManager: () => ({
    isRTL: false,
  }),
}))

describe('Screen component', () => {
  const context = {
    screenInstanceID: 'siid',
  }

  const defaultScreenConfig = {
    backButtonTitle: 'Back',
    navBarStyle: 'modal',
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
