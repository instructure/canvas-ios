/**
 * @flow
 */

import 'react-native'
import React from 'react'
import AssignmentSection from '../components/AssignmentSection'
import renderer from 'react-test-renderer'

const defaultProps = {
  title: 'foo',
}

test('render', () => {
  let tree = renderer.create(
    <AssignmentSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render no title', () => {
  delete defaultProps.title
  let tree = renderer.create(
    <AssignmentSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render first row', () => {
  let props = {
    isFirstRow: true,
  }
  delete defaultProps.title
  let tree = renderer.create(
    <AssignmentSection {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
