// @flow

import 'react-native'
import React from 'react'
import RowSeparator from '../RowSeparator'

import renderer from 'react-test-renderer'

test('render the separator', () => {
  let seperator = renderer.create(
    <RowSeparator />
  )
  expect(seperator.toJSON()).toMatchSnapshot()
})
