//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

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

test('SubmissionHeader muted grading but new gradebook', () => {
  const tree = renderer.create(
    <SubmissionsHeader
      filterOptions={defaultFilterOptions()}
      muted
      newGradebookEnabled
    />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

test('SubmissionHeader muted grading but new gradebook', () => {
  const tree = renderer.create(
    <SubmissionsHeader
      filterOptions={defaultFilterOptions()}
      muted
      anonymous
      newGradebookEnabled
    />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})
