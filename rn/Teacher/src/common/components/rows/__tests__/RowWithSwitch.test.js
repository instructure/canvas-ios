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
import RowWithSwitch from '../RowWithSwitch'

import renderer from 'react-test-renderer'

test('Render row with switch', () => {
  const onValueChange = jest.fn()
  let aRow = renderer.create(
    <RowWithSwitch
      title='Row with a switch in it!'
      onValueChange={onValueChange}
      identifier='test' />
  )
  expect(aRow.toJSON()).toMatchSnapshot()
  aRow.getInstance().onValueChange(true, 'test')
  expect(onValueChange).toHaveBeenLastCalledWith(true, 'test')
})

test('Render disabled row with switch', () => {
  const onValueChange = jest.fn()
  let aRow = renderer.create(
    <RowWithSwitch
      title='Row with a switch in it!'
      onValueChange={onValueChange}
      identifier='test'
      disabled={true} />
  )
  expect(aRow.toJSON()).toMatchSnapshot()
})
