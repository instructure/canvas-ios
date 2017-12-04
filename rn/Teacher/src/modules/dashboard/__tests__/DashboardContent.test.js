// @flow

import React from 'react'
import 'react-native'
import DashboardContent from '../DashboardContent'
import renderer from 'react-test-renderer'

test('dashboard content renders', () => {
  const tree = renderer.create(
    <DashboardContent />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
