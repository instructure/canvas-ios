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
import { shallow } from 'enzyme'
import React from 'react'
import * as template from '@templates'
import app from '@modules/app'
import DiscussionsRow from '../DiscussionsRow'

describe('DiscussionsRow', () => {
  let props
  beforeEach(() => {
    app.setCurrentApp('teacher')
    props = {
      discussion: template.discussion(),
      onPress: jest.fn(),
      index: 0,
      tintColor: '#fff',
      onToggleDiscussionGrouping: jest.fn(),
      selected: false,
    }
  })

  it('renders', () => {
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders published', () => {
    props.discussion.published = true
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders unpublished', () => {
    props.discussion.published = false
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('sends onPress', () => {
    const tree = shallow(<DiscussionsRow {...props} />)
    tree.find('[testID="discussion-row-0"]').simulate('Press')
    expect(props.onPress).toHaveBeenCalledWith(props.discussion)
  })

  it('renders without points possible', () => {
    if (props.discussion.assignment) {
      props.discussion.assignment.points_possible = null
    }
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders with points possible', () => {
    if (props.discussion.assignment) {
      props.discussion.assignment.points_possible = 12
    }
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('shows multiple due dates for teacher when assignment has overrides', () => {
    app.setCurrentApp('teacher')
    if (props.discussion.assignment) {
      props.discussion.assignment.has_overrides = true
    }
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree.find('DotSeparated').first().prop('separated')).toEqual([
      'Multiple Due Dates',
    ])
  })

  it('renders with no unread count', () => {
    props.discussion.unread_count = 0
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders with no assignment', () => {
    props.discussion.assignment = null
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree).toMatchSnapshot()
  })
})
