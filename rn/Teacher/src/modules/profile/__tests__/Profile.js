/* @flow */
const { it, expect } = global
import 'react-native'
import React from 'react'
import Profile from '../Profile.js'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

it('renders correctly', () => {
  const tree = renderer.create(
    <Profile />
  )
  const json = tree.toJSON()
  expect(json.props.testID).toEqual('module.profile')
})
