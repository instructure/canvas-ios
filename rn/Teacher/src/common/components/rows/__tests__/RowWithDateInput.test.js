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

import 'react-native'
import React from 'react'
import RowWithDateInput from '../RowWithDateInput'

import renderer from 'react-test-renderer'

test('Render row with date', () => {
  let aRow = renderer.create(
    <RowWithDateInput
      title='Row with a date in it!'
      date='this should be a date'
    />
  )
  expect(aRow.toJSON()).toMatchSnapshot()
})

test('Render row with date and the clear button', () => {
  let aRow = renderer.create(
    <RowWithDateInput
      title='Row with a date in it!'
      date='this should be a date'
      showRemoveButton={true}
    />
  )
  expect(aRow.toJSON()).toMatchSnapshot()
})
