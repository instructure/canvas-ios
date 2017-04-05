// @flow

import 'react-native'
import React from 'react'
import Token from '../Token'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('Token renders correctly', () => {
  let tree = renderer.create(
    <Token color='#0077FF'>Shiny Buckles</Token>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
