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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import React from 'react'
import {
  ContextCard,
  props,
} from '../ContextCard'
import app from '../../app'

import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

jest.mock('../../../routing/Screen')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
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
  permissions: {
    viewAnalytics: true,
    viewAllGrades: true,
    sendMessages: true,
  },
  isStudent: true,
}

beforeEach(() => {
  jest.clearAllMocks()
  app.setCurrentApp('teacher')
})

describe('ContextCard', () => {
  it('renders', () => {
    let view = renderer.create(
      <ContextCard {...defaultProps} />
    )
    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders last activity in teacher', () => {
    app.setCurrentApp('teacher')
    const view = shallow(<ContextCard {...defaultProps} />)
    const label = view.find('[testID="context-card.last-activity"]')
    expect(label).not.toBeNull()
  })

  it('does not render last activity in student', () => {
    app.setCurrentApp('student')
    const view = shallow(<ContextCard {...defaultProps} />)
    const label = view.find('[testID="context-card.last-activity"]')
    expect(label).not.toBeNull()
  })

  it('renders user name', () => {
    let props = {
      ...defaultProps,
      user: {
        ...defaultProps.user,
        short_name: 'Alfredo',
      },
    }
    let view = shallow(<ContextCard {...props} />)
    let header = shallow(view.find('FlatList').prop('ListHeaderComponent'))
    let label = header.find('[testID="ContextCard.userNameLabel"]')
    expect(label.prop('children')).toEqual('Alfredo')
  })

  it('renders user pronouns', () => {
    let props = {
      ...defaultProps,
      user: {
        ...defaultProps.user,
        short_name: 'Alfredo',
        pronouns: 'He/Him',
      },
    }
    let view = shallow(<ContextCard {...props} />)
    let header = shallow(view.find('FlatList').prop('ListHeaderComponent'))
    let label = header.find('[testID="ContextCard.userNameLabel"]')
    expect(label.prop('children')).toEqual('Alfredo (He/Him)')
  })

  it('renders for a user that cannot view analytics', () => {
    let view = renderer.create(
      <ContextCard {...defaultProps} permissions={{ ...defaultProps.permissions, viewAnalytics: false }} isStudent={false} />
    )
    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders for a user that cannot send messages', () => {
    var view = renderer.create(
      <ContextCard {...defaultProps} permissions={{ ...defaultProps.permissions, sendMessages: false }} isStudent={false} />
    )
    expect(view.toJSON()).toMatchSnapshot()
    view = renderer.create(
      <ContextCard {...defaultProps} permissions={{ ...defaultProps.permissions, sendMessages: false }} />
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
