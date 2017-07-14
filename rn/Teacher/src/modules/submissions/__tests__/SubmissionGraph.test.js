/**
 * @flow
 */

import 'react-native'
import React from 'react'
import SubmissionGraph from '../SubmissionGraph'
import renderer from 'react-test-renderer'
import setProps from '../../../../test/helpers/setProps'
import explore from '../../../../test/helpers/explore'

const defaultProps: { [string]: any } = {
  label: 'foo',
  current: 25,
  total: 100,
  pending: false,
}

test('render', () => {
  let tree = renderer.create(
    <SubmissionGraph {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 0 on graph', () => {
  defaultProps.current = 0
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

test('update progress', () => {
  const props = {
    ...defaultProps,
    current: 0,
    total: 100,
    testID: 'graded',
  }
  const view = renderer.create(
    <SubmissionGraph {...props} />
  )
  setProps(view, { current: 50, total: 100, pending: false })
  const circle: any = explore(view.toJSON()).selectByID('submissions.submission-graph.graded-progress-view')
  expect(circle.props.progress).toEqual(0.5)
})
