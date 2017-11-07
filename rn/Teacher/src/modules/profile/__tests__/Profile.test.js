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
import { NativeModules, ActionSheetIOS, Linking, AlertIOS } from 'react-native'
import React from 'react'
import Profile from '../Profile.js'
import explore from '../../../../test/helpers/explore'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'
import { setSession } from '../../../canvas-api'

const template = {
  ...require('../../../__templates__/session'),
  ...require('../../../__templates__/helm.js'),
}

jest.mock('ActionSheetIOS', () => ({
  showActionSheetWithOptions: jest.fn(),
}))

jest.mock('AlertIOS', () => ({
  alert: jest.fn(),
}))

const { navigator } = template

describe('Profile Tests', () => {
  beforeEach(() => {
    setSession(template.session())
    jest.resetAllMocks()

    NativeModules.RNMail = {
      ...NativeModules.RNMail,
      canSendMail: true,
    }
  })
  it('renders correctly', () => {
    const tree = renderer.create(
      <Profile navigator={navigator} />
    ).toJSON()

    expect(tree).toMatchSnapshot()

    const view = explore(tree).selectByID('module.profile') || {}
    expect(view.props.accessible).toBeTruthy()
  })

  it('logout called', () => {
    const instance = renderer.create(
      <Profile navigator={navigator} />
    ).getInstance()

    instance.logout()
    expect(NativeModules.NativeLogin.logout).toHaveBeenCalled()
  })

  it('shows the action sheet', () => {
    const instance = renderer.create(
      <Profile navigator={navigator} />
    ).getInstance()

    instance.settings()
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
  })

  it('redirects to Canvas Guides', () => {
    const instance = renderer.create(
      <Profile navigator={navigator} />
    ).getInstance()

    instance.handleActions(0)
    expect(Linking.openURL).toHaveBeenCalled()
  })

  it('redirects to Terms of Use', () => {
    const instance = renderer.create(
      <Profile navigator={navigator} />
    ).getInstance()

    instance.handleActions(2)
    expect(Linking.openURL).toHaveBeenCalled()
  })

  it('opens mail app to report a problem', () => {
    const mail = jest.fn((data, cb) => {
      cb()
    })
    NativeModules.RNMail = {
      ...NativeModules.RNMail,
      mail,
      canSendMail: true,
    }

    const instance = renderer.create(
      <Profile navigator={navigator} />
    ).getInstance()

    instance.handleActions(1)
    expect(NativeModules.RNMail.mail).toHaveBeenCalled()
  })

  it('fails to send mail', () => {
    const mail = jest.fn((data, cb) => {
      cb('failed')
    })
    NativeModules.RNMail = {
      ...NativeModules.RNMail,
      mail,
      canSendMail: true,
    }

    const instance = renderer.create(
      <Profile navigator={navigator} />
    ).getInstance()

    instance.handleActions(1)
    expect(AlertIOS.alert).toHaveBeenCalled()
  })

  it('mail app is not configured, so hitting the button at index 1 should open a link', () => {
    NativeModules.RNMail = {
      ...NativeModules.RNMail,
      canSendMail: false,
    }

    const instance = renderer.create(
      <Profile navigator={navigator} />
    ).getInstance()

    instance.handleActions(1)
    expect(Linking.openURL).toHaveBeenCalled()
  })

  it('cancel the action sheet', () => {
    const instance = renderer.create(
      <Profile navigator={navigator} />
    ).getInstance()

    instance.handleActions(3)
    expect(Linking.openURL).not.toHaveBeenCalled()
    expect(NativeModules.RNMail.mail).not.toHaveBeenCalled()
  })

  it('secret tap!', () => {
    const navigator = template.navigator()
    const instance = renderer.create(
      <Profile navigator={navigator}/>
    ).getInstance()
    var times = 12
    for (var i = 0; i < times; i++) {
      instance.secretTap()
    }
    expect(navigator.show).toHaveBeenCalled()
  })

  it('render with no session', () => {
    setSession(null)
    const tree = renderer.create(
      <Profile navigator={navigator}/>
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
