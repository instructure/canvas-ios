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
import 'react-native'
import GroupRow from '../GroupRow'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

let props = {
  style: { margin: 8 },
  id: '1',
  color: 'blue',
  name: 'Study Group 3',
  contextName: 'Bio 101',
  term: 'Spring 2020',
  onPress: jest.fn(),
}

describe('GroupRow', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders', () => {
    const tree = renderer.create(
      <GroupRow {...props} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders without a term', () => {
    const tree = renderer.create(
      <GroupRow {...props} term={undefined} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('calls onPress with the group id when pressed', () => {
    const view = renderer.create(
      <GroupRow {...props} />
    )
    let group = explore(view.toJSON()).selectByID('group-row-1') || {}
    group.props.onPress()
    expect(props.onPress).toHaveBeenCalledWith('1')
  })
})
