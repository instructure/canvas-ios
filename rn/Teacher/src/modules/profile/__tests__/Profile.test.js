/* @flow */
import 'react-native'
import React from 'react'
import Profile from '../Profile.js'
import explore from '../../../../test/helpers/explore'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'
import { setSession } from '../../../api/session'
import * as template from '../../../api/canvas-api/__templates__/session'

describe('Profile Tests', () => {
  beforeEach(() => {
    setSession(template.session())
  })
  it('renders correctly', () => {
    const tree = renderer.create(
      <Profile />
    ).toJSON()

    expect(tree).toMatchSnapshot()

    const view = explore(tree).selectByID('module.profile') || {}
    expect(view.props.accessible).toBeTruthy()
  })
})
