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

import React from 'react'
import {
  ContextCard,
  props,
} from '../ContextCard'

import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

jest.mock('../../../routing/Screen')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../common/components/ErrorView.js', () => 'ErrorView')

const templates = {
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/enrollments'),
  ...require('../../../__templates__/users'),
  ...require('../../../__templates__/section'),
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/submissions'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../canvas-api-v2/queries/__templates__/ContextCard'),
}

const user = templates.user({ id: '1', analytics: { tardinessBreakdown: { late: 10, missing: 20 } } })
const defaultProps = {
  courseID: '1',
  userID: '1',
  user,
  course: templates.course({ id: '1' }),
  enrollment: templates.enrollment({ id: '1', course_id: '1', user_id: '1', course_section_id: '32', grades: { current_grade: 'A', current_score: 50 }, section: templates.section() }),
  submissions: [templates.submission({ id: '1', assignment_id: '1', grade: 50, assignment: templates.assignment({ id: '1', points_possible: 100 }) })],
  courseColor: '#fff',
  navigator: { dismiss: jest.fn(), show: jest.fn() },
  refresh: jest.fn(),
  loading: false,
  modal: false,
  canViewAnalytics: true,
  canViewGrades: true,
  isStudent: true,
}

beforeEach(() => jest.resetAllMocks())

describe('ContextCard', () => {
  it('renders', () => {
    let view = renderer.create(
      <ContextCard {...defaultProps} />
    )
    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders for a user that cannot view analytics', () => {
    let view = renderer.create(
      <ContextCard {...defaultProps} canViewAnalytics={false} isStudent={false} />
    )
    expect(view.toJSON()).toMatchSnapshot()
  })

  it('shows the activity indicator when pending', () => {
    let view = renderer.create(
      <ContextCard {...defaultProps} loading={true} course={null} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('formats the last_activity_at properly', () => {
    let enrollment = templates.enrollment({
      id: '1',
      course_id: '1',
      user_id: '1',
      course_section_id: '32',
      last_activity_at: '2017-04-05T15:12:45Z',
      grades: {
        current_grade: '100',
      },
      section: templates.section(),
    })
    let view = renderer.create(
      <ContextCard {...defaultProps} enrollment={enrollment} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('shows points values when there is no grade', () => {
    let enrollment = templates.enrollment({
      id: '1',
      course_id: '1',
      user_id: '1',
      course_section_id: '32',
      last_activity_at: '2017-04-05T15:12:45Z',
      grades: {
        current_score: 100,
      },
      section: templates.section(),
    })

    let view = renderer.create(
      <ContextCard {...defaultProps} enrollment={enrollment} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders for a non student', () => {
    let enrollment = templates.enrollment({
      id: '1',
      course_id: '1',
      user_id: '1',
      course_section_id: '32',
      type: 'TeacherEnrollment',
      section: templates.section(),
    })

    let view = renderer.create(
      <ContextCard {...defaultProps} enrollment={enrollment} isStudent={false} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders error if an error occured', () => {
    let view = renderer.create(
      <ContextCard {...defaultProps} error={Error('oh no an error happened')} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders if there is no enrollment', () => {
    let view = renderer.create(
      <ContextCard {...defaultProps} enrollment={null} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders if there is no section in the enrollment', () => {
    let enrollment = templates.enrollment({ id: '1', course_id: '1', user_id: '1', course_section_id: '32' })
    let view = renderer.create(
      <ContextCard {...defaultProps} enrollment={enrollment} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('navigate to speedgrader', () => {
    let view = renderer.create(
      <ContextCard {...defaultProps} />
    )
    let assignmentID = defaultProps.submissions[0].assignment.id
    let row = explore(view.toJSON()).selectByID(`user-submission-row.cell-${assignmentID}`)
    expect(row).not.toBeNull()
    row && row.props.onPress()

    expect(defaultProps.navigator.show).toHaveBeenCalled()
  })

  it('navigates to composer', () => {
    defaultProps.navigator.show = jest.fn()
    let view = renderer.create(
      <ContextCard {...defaultProps} />
    )
    const tree = view.toJSON()
    const mailButton: any = explore(tree).selectRightBarButton('context-card.email-contact')
    expect(mailButton).not.toBeNull()
    mailButton.action()
    let expectedProps = { 'canSelectCourse': false, 'contextCode': `course_${defaultProps.course.id}`, 'contextName': `${defaultProps.course.name}`, 'recipients': [user] }
    expect(defaultProps.navigator.show).toHaveBeenCalledWith(`/conversations/compose`, { 'modal': true }, expectedProps)
  })
})

describe('props', () => {
  it('should parse the props correctly from graphql data', () => {
    const data = templates.ContextCardResult()
    const result = props({ data })
    expect(result.course).toMatchObject(data.course)
    expect(result.user).toMatchObject(data.course.users.edges[0].user)
  })

  it('should parse the props correctly in an error case', () => {
    const data = { error: Error('there was an error run for the hills') }
    const result = props({ data })
    expect(result.error).toMatchObject(data.error)
  })

  it('should parse the props and get the loading state correctly', () => {
    const data = templates.ContextCardResult()
    data.course = null
    data.loading = true
    const result = props({ data })
    expect(result).toMatchObject({ loading: true })
  })

  it('should parse the props and if user or course is missing it should bail', () => {
    const data = templates.ContextCardResult()
    data.course = null
    const result = props({ data })
    expect(result.error).toBeDefined()
  })
})
