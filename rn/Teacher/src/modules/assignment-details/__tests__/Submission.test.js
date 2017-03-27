/**
 * @flow
 */

import 'react-native'
import React from 'react'
import Submission from '../components/Submission'
import renderer from 'react-test-renderer'

test('render', () => {
  let tree = renderer.create(
    <Submission data={[25]} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 0 submissions', () => {
  let tree = renderer.create(
    <Submission data={[0]} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render multiple data points ', () => {
  let tree = renderer.create(
    <Submission data={[10, 20, 30]} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
