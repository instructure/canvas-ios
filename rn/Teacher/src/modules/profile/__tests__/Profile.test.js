/* @flow */
import { NativeModules, ActionSheetIOS, Linking, AlertIOS } from 'react-native'
import React from 'react'
import Profile from '../Profile.js'
import explore from '../../../../test/helpers/explore'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'
import { setSession } from '../../../api/session'

const template = {
  ...require('../../../api/canvas-api/__templates__/session'),
  ...require('../../../__templates__/helm.js'),
}

jest.mock('ActionSheetIOS', () => ({
  showActionSheetWithOptions: jest.fn(),
}))

jest.mock('AlertIOS', () => ({
  alert: jest.fn(),
}))

describe('Profile Tests', () => {
  beforeEach(() => {
    setSession(template.session())
    jest.resetAllMocks()
  })
  it('renders correctly', () => {
    const tree = renderer.create(
      <Profile />
    ).toJSON()

    expect(tree).toMatchSnapshot()

    const view = explore(tree).selectByID('module.profile') || {}
    expect(view.props.accessible).toBeTruthy()
  })

  it('logout called', () => {
    const instance = renderer.create(
      <Profile />
    ).getInstance()

    instance.logout()
    expect(NativeModules.NativeLogin.logout).toHaveBeenCalled()
  })

  it('shows the action sheet', () => {
    const instance = renderer.create(
      <Profile />
    ).getInstance()

    instance.settings()
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
  })

  it('redirects to Canvas Guides', () => {
    const instance = renderer.create(
      <Profile />
    ).getInstance()

    instance.handleActions(0)
    expect(Linking.openURL).toHaveBeenCalled()
  })

  it('redirects to Terms of Use', () => {
    const instance = renderer.create(
      <Profile />
    ).getInstance()

    instance.handleActions(2)
    expect(Linking.openURL).toHaveBeenCalled()
  })

  it('redirects to Terms of Use', () => {
    const instance = renderer.create(
      <Profile />
    ).getInstance()

    instance.handleActions(10)
  })

  it('opens mail app to report a problem', () => {
    const mail = jest.fn((data, cb) => {
      cb()
    })
    NativeModules.RNMail = {
      ...NativeModules.RNMail,
      mail,
    }

    const instance = renderer.create(
      <Profile />
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
    }

    const instance = renderer.create(
      <Profile />
    ).getInstance()

    instance.handleActions(1)
    expect(AlertIOS.alert).toHaveBeenCalled()
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
      <Profile />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
