/**
 * @flow
 */

import 'react-native'
import React from 'react'
import SubmissionGraph from '../components/SubmissionGraph'
import renderer from 'react-test-renderer'

const defaultProps: { [string]: any } = {
  label: 'foo',
  data: 25,
}

test('render', () => {
  let tree = renderer.create(
    <SubmissionGraph {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 0 on graph', () => {
  defaultProps.data = 0
  let tree = renderer.create(
    <SubmissionGraph {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render undefined label', () => {
  defaultProps.label = undefined
  let tree = renderer.create(
    <SubmissionGraph {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
