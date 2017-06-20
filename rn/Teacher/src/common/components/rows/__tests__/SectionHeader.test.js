// @flow

import 'react-native'
import React from 'react'
import SectionHeader from '../SectionHeader'

import renderer from 'react-test-renderer'

test('render', () => {
  let header = renderer.create(
    <SectionHeader
      title='Header'
      key='key' />
  )
  expect(header.toJSON()).toMatchSnapshot()
})

test('render without key', () => {
  let header = renderer.create(
    <SectionHeader
      title='Header'
      top={true} />
  )
  expect(header.toJSON()).toMatchSnapshot()
})
