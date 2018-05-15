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
