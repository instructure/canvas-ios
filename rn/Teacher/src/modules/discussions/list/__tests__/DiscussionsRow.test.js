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

/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import DiscussionsRow, { type Props } from '../DiscussionsRow'
import explore from '../../../../../test/helpers/explore'

jest.mock('Button', () => 'Button').mock('TouchableHighlight', () => 'TouchableHighlight').mock('TouchableOpacity', () => 'TouchableOpacity')

const template = {
  ...require('../../../../__templates__/discussion'),
}

describe('DiscussionsRow', () => {
  let props
  beforeEach(() => {
    props = {
      discussion: template.discussion(),
      onPress: jest.fn(),
      index: 0,
      tintColor: '#fff',
      onToggleDiscussionGrouping: jest.fn(),
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders published', () => {
    props.discussion.published = true
    testRender(props)
  })

  it('renders unpublished', () => {
    props.discussion.published = false
    testRender(props)
  })

  it('sends onPress', () => {
    const tree = render(props).toJSON()
    const row : any = explore(tree).selectByID('discussion-row-0')
    row.props.onPress()
    expect(props.onPress).toHaveBeenCalledWith(props.discussion)
  })

  it('renders without points possible', () => {
    if (props.discussion.assignment) {
      props.discussion.assignment.points_possible = null
    }
    testRender(props)
  })

  it('renders with points possible', () => {
    if (props.discussion.assignment) {
      props.discussion.assignment.points_possible = 12
    }
    testRender(props)
  })

  it('renders with no unread count', () => {
    props.discussion.unread_count = 0
    testRender(props)
  })

  it('renders with no assignment', () => {
    props.discussion.assignment = null
    testRender(props)
  })

  function testRender (props: Props) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: Props): any {
    return renderer.create(<DiscussionsRow {...props}/>)
  }
})
