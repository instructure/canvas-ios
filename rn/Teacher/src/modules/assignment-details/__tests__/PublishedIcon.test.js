/**
 * @flow
 */

import 'react-native'
import React from 'react'
import PublishedIcon from '../components/PublishedIcon'
import renderer from 'react-test-renderer'

test('render published', () => {
  let tree = renderer.create(
    <PublishedIcon published={true} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render unpublished', () => {
  let tree = renderer.create(
    <PublishedIcon published={false} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render larger icon size', () => {
  let tree = renderer.create(
    <PublishedIcon published={true} iconSize={75} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
