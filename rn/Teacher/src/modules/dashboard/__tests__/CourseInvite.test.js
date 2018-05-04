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
    tree.find('[testID="course-invite.1.accept-button"]').simulate('Press')
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
    tree.find('[testID="course-invite.1.reject-button"]').simulate('Press')
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
    tree.find('[testID="course-invite.1.dismiss-button"]').simulate('Press')
    expect(tree).toMatchSnapshot()
  })
})
