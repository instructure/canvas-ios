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

// @flow
import React from 'react'
import SubmissionsHeader from '../SubmissionsHeader.js'
import renderer from 'react-test-renderer'
import defaultFilterOptions from '../../filter/filter-options'
import explore from '../../../../test/helpers/explore'

let template = {
  ...require('../../../__templates__/helm'),
}

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

test('SubmissionHeader navigates to filter when pressed', () => {
  let navigator = template.navigator()
  let filterOptions = defaultFilterOptions()
  const tree = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} navigator={navigator} />
  ).toJSON()

  let filterButton = explore(tree).selectByID('submission-list.filter') || {}
  filterButton.props.onPress()

  expect(navigator.show).toHaveBeenCalledWith(
    '/filter',
    { modal: true },
    { filterOptions, navigator }
  )
})

test('SubmissionHeader anonymous grading', () => {
  const tree = renderer.create(
    <SubmissionsHeader filterOptions={defaultFilterOptions()} anonymous />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

test('SubmissionHeader muted grading', () => {
  const tree = renderer.create(
    <SubmissionsHeader filterOptions={defaultFilterOptions()} muted />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

test('SubmissionHeader anonymous and muted', () => {
  const tree = renderer.create(
    <SubmissionsHeader filterOptions={defaultFilterOptions()} anonymous muted />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})
