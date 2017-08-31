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
