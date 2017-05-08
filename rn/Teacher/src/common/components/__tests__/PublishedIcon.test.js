/* @flow */

import 'react-native'
import React from 'react'
import PublishedIcon from '../PublishedIcon'
import Images from '../../../images'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders published correctly', () => {
  let tree = renderer.create(
    <PublishedIcon published={true} tintColor='#fff' image={Images.kabob} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders unpublished correctly', () => {
  let tree = renderer.create(
    <PublishedIcon published={false} tintColor='#fff' image={Images.kabob} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
