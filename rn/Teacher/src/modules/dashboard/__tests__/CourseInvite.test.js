//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import React from 'react'
import { enrollment } from '../../../__templates__/enrollments'
import CourseInvite from '../CourseInvite'

describe('CourseInvite', () => {
  const defaults = {
    invite: enrollment({ id: '1', course_id: '2', enrollment_state: 'invited' }),
    courseName: 'Coolest Course',
    sectionName: 'Worst Section eva',
    handleInvite: jest.fn(),
    hideInvite: jest.fn(),
  }

  it('renders invite', () => {
    const tree = shallow(
      <CourseInvite {...defaults} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders invite with course section', () => {
    const props = {
      ...defaults,
      sectionName: defaults.courseName,
    }
    const tree = shallow(
      <CourseInvite {...props} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders hidden', () => {
    const tree = shallow(
      <CourseInvite {...defaults} hidden={true} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders action taken -- accept', () => {
    const props = {
      ...defaults,
      invite: enrollment({ id: '1', course_id: '2', enrollment_state: 'active', displayState: 'acted' }),
    }
    const tree = shallow(
      <CourseInvite {...props} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders action taken -- reject', () => {
    const props = {
      ...defaults,
      invite: enrollment({ id: '1', course_id: '2', enrollment_state: 'rejected', displayState: 'acted' }),
    }
    const tree = shallow(
      <CourseInvite {...props} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders displayState acted -- accept', () => {
    let props = {
      ...defaults,
      invite: enrollment({ id: '1', course_id: '2', enrollment_state: 'active', displayState: 'acted' }),
    }
    const tree = shallow(
      <CourseInvite {...props} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders displayState acted -- reject', () => {
    let props = {
      ...defaults,
      invite: enrollment({ id: '1', course_id: '2', enrollment_state: 'rejected', displayState: 'acted' }),
    }
    const tree = shallow(
      <CourseInvite {...props} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('can accept', () => {
    const props = {
      ...defaults,
      handleInvite: jest.fn(),
    }
    const tree = shallow(
      <CourseInvite {...props} />
    )
    tree.find('[testID="CourseInvitation.1.acceptButton"]').simulate('Press')
    expect(props.handleInvite).toHaveBeenCalledWith('2', '1', 'accept')
  })

  it('can reject', () => {
    const props = {
      ...defaults,
      handleInvite: jest.fn(),
    }
    const tree = shallow(
      <CourseInvite {...props} />
    )
    tree.find('[testID="CourseInvitation.1.rejectButton"]').simulate('Press')
    expect(props.handleInvite).toHaveBeenCalledWith('2', '1', 'reject')
  })

  it('can hide', () => {
    const props = {
      ...defaults,
      hideInvite: jest.fn(),
      invite: enrollment({ id: '1', course_id: '2', enrollment_state: 'rejected', displayState: 'acted' }),
    }
    const tree = shallow(
      <CourseInvite {...props} />
    )
    tree.find('[testID="CourseInvitation.1.dismissButton"]').simulate('Press')
    expect(tree).toMatchSnapshot()
  })
})
