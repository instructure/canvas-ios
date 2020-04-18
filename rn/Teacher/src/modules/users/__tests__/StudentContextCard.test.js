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
} from '../StudentContextCard'
import app from '../../app'

jest.mock('../../../routing/Screen')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../common/components/ErrorView.js', () => 'ErrorView')

const templates = {
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/group'),
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
  context: templates.course({ id: '1' }),
  contextType: 'courses',
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
  it('renders course', () => {
    let tree = shallow(
      <ContextCard {...defaultProps} />
    )
    let list = tree.find('FlatList')
    expect(list.exists()).toEqual(true)
    expect(list.props().data).toEqual(defaultProps.submissions)

    let header = shallow(tree.instance().renderHeader())
    expect(header.find('[testID="context-card.context-name"]').props().children).toEqual(defaultProps.context.name)
    expect(header.find('[testID="context-card.section-name"]').props().children).toContain(defaultProps.enrollment.section.name)
    expect(header.find('[testID="context-card.analytics"]').exists()).toEqual(true)
  })

  it('renders group', () => {
    let props = {
      ...defaultProps,
      context: templates.group({ id: '1' }),
      enrollment: {},
      submissions: [],
      permissions: {},
    }
    let tree = shallow(
      <ContextCard {...props} />
    )
    let list = tree.find('FlatList')
    expect(list.exists()).toEqual(true)
    expect(list.props().data).toEqual(props.submissions)

    let header = shallow(tree.instance().renderHeader())
    expect(header.find('[testID="context-card.context-name"]').props().children).toEqual(props.context.name)
    expect(header.find('[testID="context-card.section-name"]').exists()).toEqual(false)
    expect(header.find('[testID="context-card.analytics"]').exists()).toEqual(false)
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

  it('renders for a user that cannot view analytics', () => {
    let tree = shallow(
      <ContextCard {...defaultProps} permissions={{ ...defaultProps.permissions, viewAnalytics: false }} isStudent={false} />
    )
    expect(tree.find('FlatList').props().data).toEqual([])
  })

  it('renders for a user that cannot send messages', () => {
    let tree = shallow(
      <ContextCard {...defaultProps} permissions={{ ...defaultProps.permissions, sendMessages: false }} isStudent={false} />
    )
    expect(tree.find('Screen').props().rightBarButtons[0].accessibilityLabel).toEqual('Send message')

    tree = shallow(
      <ContextCard {...defaultProps} permissions={{ ...defaultProps.permissions, sendMessages: false }} />
    )
    expect(tree.find('Screen').props().rightBarButtons.length).toEqual(0)
  })

  it('shows the activity indicator when pending', () => {
    let tree = shallow(
      <ContextCard {...defaultProps} loading={true} context={null} />
    )
    expect(tree.find('ActivityIndicatorView').exists()).toEqual(true)
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
    let tree = shallow(
      new ContextCard({ ...defaultProps, enrollment }).renderHeader()
    )
    let lastActivity = tree.find('[testID="context-card.last-activity"]')
    expect(lastActivity.props().children).toContain('April 5 at 9:12 AM')
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

    let tree = shallow(
      new ContextCard({ ...defaultProps, enrollment }).renderHeader()
    )
    expect(tree.find('[testID="context-card.grade"]').props().children).toEqual('100%')
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

    let tree = shallow(
      <ContextCard {...defaultProps} enrollment={enrollment} isStudent={false} />
    )
    expect(tree.find('FlatList').props().data).toEqual([])

    let header = shallow(tree.instance().renderHeader())
    expect(header.find('Avatar').exists()).toEqual(true)
    expect(header.find('[testID="context-card.short-name"]').exists()).toEqual(true)
    expect(header.find('[testID="context-card.analytics"]').exists()).toEqual(false)
  })

  it('renders error if an error occured', () => {
    let tree = shallow(
      <ContextCard {...defaultProps} error={Error('oh no an error happened')} />
    )
    expect(tree.find('ErrorView').exists()).toEqual(true)
  })

  it('renders if there is no enrollment', () => {
    let tree = shallow(
      new ContextCard({ ...defaultProps, enrollment: null }).renderHeader()
    )
    expect(tree.find('Avatar').exists()).toEqual(true)
    expect(tree.find('[testID="context-card.last-activity"]').exists()).toEqual(false)
    expect(tree.find('[testID="context-card.grade"]').exists()).toEqual(false)
  })

  it('renders if there is no section in the enrollment', () => {
    let enrollment = templates.enrollment({ id: '1', course_id: '1', user_id: '1', course_section_id: '32' })
    let tree = shallow(
      new ContextCard({ ...defaultProps, enrollment }).renderHeader()
    )
    expect(tree.find('[testID="context-card.section-name"]').exists()).toEqual(false)
    expect(tree.find('[testID="context-card.context-name"]').exists()).toEqual(true)
  })

  it('navigate to speedgrader', () => {
    let row = shallow(
      new ContextCard({ ...defaultProps }).renderItem({ item: defaultProps.submissions[0], index: 0 })
    )
    row.props().onPress()
    expect(defaultProps.navigator.show).toHaveBeenCalled()
  })

  it('navigates to composer', () => {
    defaultProps.navigator.show = jest.fn()
    let tree = shallow(
      <ContextCard {...defaultProps} />
    )
    const mailButton = tree.find('Screen').props().rightBarButtons[0]
    expect(mailButton).not.toBeNull()
    mailButton.action()
    let expectedProps = { 'canSelectCourse': false, 'contextCode': `course_${defaultProps.context.id}`, 'contextName': `${defaultProps.context.name}`, 'recipients': [user] }
    expect(defaultProps.navigator.show).toHaveBeenCalledWith(`/conversations/compose`, { 'modal': true }, expectedProps)
  })
})

describe('props', () => {
  it('should parse the props correctly from graphql data', () => {
    const data = templates.ContextCardResult()
    const result = props({ data })
    expect(result.context).toMatchObject(data.course)
    expect(result.contextType).toEqual('courses')
    expect(result.user).toMatchObject(data.course.users.edges[0].user)
  })

  it('should parse the props correctly for groups from graphql data', () => {
    const data = templates.ContextCardGroupResult()
    const result = props({ data })
    expect(result.context).toMatchObject(data.group)
    expect(result.contextType).toEqual('groups')
    expect(result.user).toMatchObject(data.group.member.user)
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
