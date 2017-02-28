/* @flow */
const { it, expect } = global
import 'react-native'
import React from 'react'
import Profile from '../Profile.js'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

import explore from '../../../utils/explore'

it('renders correctly', () => {
  const tree = renderer.create(
    <Profile />
  ).toJSON()

  expect(tree).toMatchSnapshot()

  const view = explore(tree).selectByID('module.profile') || {}
  expect(view.props.accessible).toBeTruthy()
})
