//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* eslint-disable flowtype/require-valid-file-annotation */

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
