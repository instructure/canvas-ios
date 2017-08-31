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
import { ActionSheetIOS, AlertIOS } from 'react-native'
import React from 'react'
import SubmissionsHeader from '../SubmissionsHeader.js'
import renderer from 'react-test-renderer'

jest.mock('ActionSheetIOS', () => ({
  showActionSheetWithOptions: jest.fn(),
}))
jest.mock('AlertIOS', () => ({
  prompt: jest.fn(),
}))

const filterOptions = [
  {
    type: 'all',
    title: 'all',
  },
  {
    type: 'late',
    title: 'late',
    filterFunc: (submissions: any) => submissions.filter((s) => s.status === 'late'),
  },
  {
    type: 'morethan',
    title: 'morethan',
  },
  {
    type: 'lessthan',
    title: 'lessthan',
  },
  {
    type: 'cancel',
    title: 'cancel',
  }]

test('SubmissionsHeader chose filter function', () => {
  const instance = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} />
  ).getInstance()
  instance.chooseFilter()

  expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalledWith({
    options: [
      'all',
      'late',
      'morethan',
      'lessthan',
      'cancel',
    ],
    cancelButtonIndex: 4,
    title: 'Filter by:',
  }, instance.updateFilter)
})

test('SubmissionsHeader update filter', () => {
  const onSelectFilter = jest.fn()
  const instance = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} onSelectFilter={onSelectFilter} />
  ).getInstance()

  instance.updateFilter(1)

  expect(onSelectFilter).toHaveBeenCalledWith({
    filter: instance.props.filterOptions[1],
  })
})

test('SubmissionsHeader update filter', () => {
  const onSelectFilter = jest.fn()
  const instance = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} onSelectFilter={onSelectFilter} />
  ).getInstance()

  let callback
  const prompt = jest.fn((title, message, cb) => {
    callback = cb
  })
  // $FlowFixMe
  AlertIOS.prompt = prompt
  instance.updateFilter(3)
  expect(prompt).toHaveBeenCalled()
  if (callback) {
    callback()
  }
  expect(onSelectFilter).toHaveBeenCalledWith({
    filter: instance.props.filterOptions[3],
  })
})

test('SubmissionsHeader cancel and clear', () => {
  const onSelectFilter = jest.fn()
  const onClearFilter = jest.fn()
  const instance = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} onSelectFilter={onSelectFilter} onClearFilter={onClearFilter} />
  ).getInstance()

  instance.updateFilter(4)
  expect(onSelectFilter).not.toHaveBeenCalled()

  instance.clearFilter()
  expect(onClearFilter).toHaveBeenCalled()
})

test('SubmissionHeader anonymous grading', () => {
  const tree = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} anonymous />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

test('SubmissionHeader muted grading', () => {
  const tree = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} muted />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

test('SubmissionHeader anonymous and muted', () => {
  const tree = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} anonymous muted />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})
