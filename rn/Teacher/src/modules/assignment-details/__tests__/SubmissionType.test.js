/**
 * @flow
 */

import 'react-native'
import React from 'react'
import SubmissionType from '../components/SubmissionType'
import renderer from 'react-test-renderer'

const defaultProps = {
  data: ['foo', 'bar'],
}

test('render', () => {
  let tree = renderer.create(
    <SubmissionType {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 0 types', () => {
  defaultProps.data = []
  let tree = renderer.create(
    <SubmissionType {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render single type', () => {
  defaultProps.data = ['foo']
  let tree = renderer.create(
    <SubmissionType {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
