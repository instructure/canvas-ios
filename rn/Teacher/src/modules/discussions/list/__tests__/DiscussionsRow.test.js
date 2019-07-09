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
    tree.find(`[testID="DiscussionListCell.${props.discussion.id}"]`).simulate('Press')
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
