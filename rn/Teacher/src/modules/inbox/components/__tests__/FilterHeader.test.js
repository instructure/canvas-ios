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
import FilterHeader from '../FilterHeader'
import explore from '../../../../../test/helpers/explore'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

it('renders correctly', () => {
  const tree = renderer.create(
    <FilterHeader selected={'all'} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('calls the passed in callback', () => {
  const callback = jest.fn()
  const tree = renderer.create(
    <FilterHeader selected={'all'} onFilterChange={callback}/>
  ).toJSON()
  const button = explore(tree).selectByID('inbox.filter-btn-unread') || {}
  button.props.onPress()
  expect(callback).toHaveBeenCalledWith('unread')
})
