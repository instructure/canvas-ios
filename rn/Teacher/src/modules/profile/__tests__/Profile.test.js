/* @flow */
import { NativeModules, ActionSheetIOS, Linking } from 'react-native'
import React from 'react'
import Profile from '../Profile.js'
import explore from '../../../../test/helpers/explore'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'
import { setSession } from '../../../api/session'
import * as template from '../../../api/canvas-api/__templates__/session'

jest.mock('ActionSheetIOS', () => ({
  showActionSheetWithOptions: jest.fn(),
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

  it('opens mail app to report a problem', () => {
    NativeModules.RNMail = {
      ...NativeModules.RNMail,
      mail: jest.fn(),
    }

    const instance = renderer.create(
      <Profile />
    ).getInstance()

    instance.handleActions(1)
    expect(NativeModules.RNMail.mail).toHaveBeenCalled()
  })
})
