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
import * as template from '../../../../__templates__'
import app from '../../../app'
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

    expect(tree.find('Row').prop('title')).toEqual(props.discussion.title)
    expect(tree.find('Row').prop('selected')).toEqual(props.selected)
    expect(tree.find('DotSeparated').at(0).prop('separated')).toEqual(['Due May 31, 2037 at 11:59 PM'])
  })

  it('sends onPress', () => {
    const tree = shallow(<DiscussionsRow {...props} />)
    tree.find(`[testID="DiscussionListCell.${props.discussion.id}"]`).simulate('press')
    expect(props.onPress).toHaveBeenCalledWith(props.discussion)
  })

  it('renders without points possible', () => {
    props.discussion.assignment.points_possible = null
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree.find('[testID="discussion.row.points"]').exists()).toEqual(false)
  })

  it('renders with points possible', () => {
    props.discussion.assignment.points_possible = 12
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree.find('[testID="discussion.row.points"] Text').prop('children')).toEqual('12 pts')
  })

  it('shows multiple due dates for teacher when assignment has overrides', () => {
    app.setCurrentApp('teacher')
    props.discussion.assignment.has_overrides = true
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree.find('DotSeparated').first().prop('separated')).toEqual([
      'Multiple Due Dates',
    ])
  })

  it('renders with no unread count', () => {
    props.discussion.unread_count = 0
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree.find('[testID="discussion.row.details"] DotSeparated').prop('separated')).toEqual(['2 Replies', '0 Unread'])
  })

  it('renders with an unread count', () => {
    props.discussion.unread_count = 2
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree.find('[testID="discussion.row.details"] DotSeparated').prop('separated')).toEqual(['2 Replies', '2 Unread'])
  })

  it('renders no replies', () => {
    props.discussion.discussion_subentry_count = 0
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree.find('[testID="discussion.row.details"] DotSeparated').prop('separated')).toEqual(['0 Replies', '1 Unread'])
  })

  it('renders the unread dot', () => {
    props.discussion.unread_count = 2
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree.find('[testID="discussions.row.unread-dot"]').prop('style')).not.toBeUndefined()
  })

  it('does not render the unread dot', () => {
    props.discussion.unread_count = 0
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree.find('[testID="discussions.row.unread-dot"]').prop('style')).toBeUndefined()
  })

  it('renders with no assignment', () => {
    props.discussion.assignment = null
    const tree = shallow(<DiscussionsRow {...props} />)
    expect(tree.find('DotSeparated').at(0).prop('separated')).toEqual(['Last post Dec 10, 2016 at 9:03 PM'])
  })
})
