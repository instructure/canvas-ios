/**
 * @flow
 */

import 'react-native'
import React from 'react'
import EditSectionHeader from '../components/EditSectionHeader'
import renderer from 'react-test-renderer'

const defaultProps = {
  title: 'foo',
}

test('render', () => {
  let tree = renderer.create(
    <EditSectionHeader {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render no title', () => {
  let props = Object.assign({}, defaultProps)
  delete props.title
  let tree = renderer.create(
    <EditSectionHeader {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
