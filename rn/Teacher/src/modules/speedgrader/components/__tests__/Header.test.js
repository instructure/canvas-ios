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
import _ from 'lodash'
import React from 'react'
import { Header, mapStateToProps } from '../Header'
import * as templates from '../../../../__templates__'

let noSubProps = {
  submissionID: null,
  assignmentID: '2',
  courseID: '3',
  userID: '4',
  assignmentSubmissionTypes: [ 'online_upload' ],
  submissionProps: {
    name: 'Allura',
    avatarURL: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
    status: 'none',
    userID: '4',
    grade: 'not_submitted',
    submissionID: null,
    submission: null,
  },
  closeModal: jest.fn(),
  excuseAssignment: jest.fn(),
  gradeSubmission: jest.fn(),
  selectSubmissionFromHistory: jest.fn(),
  selectedIndex: null,
  selectedAttachmentIndex: null,
  anonymous: false,
  navigator: templates.navigator(),
}

let subProps = {
  ...noSubProps,
  submissionID: '1',
  submissionProps: {
    name: 'Allura',
    avatarURL: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
    status: 'submitted',
    userID: '4',
    grade: '5',
    submissionID: '1',
    submission: templates.submissionHistory([
      { id: '1', grade: null, submitted_at: '2017-04-26T17:46:00Z' },
      { id: '2', grade: null, submitted_at: '2016-01-01T00:01:00Z' },
    ]),
  },
}

let groupProps = {
  ...subProps,
  submissionProps: {
    ...subProps.submissionProps,
    groupID: '1',
  },
}

describe('SpeedGraderHeader', () => {
  beforeEach(() => jest.clearAllMocks())

  it('renders with no submission', () => {
    let tree = shallow(<Header {...noSubProps} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders with a submission', () => {
    let tree = shallow(<Header {...subProps} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders with a group submission', () => {
    let tree = shallow(<Header {...groupProps} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders with a grade-only submission', () => {
    let props = _.cloneDeep(subProps)
    props.submissionProps.status = 'none'

    let tree = shallow(<Header {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders with an over-due grade-only submission', () => {
    let props = _.cloneDeep(subProps)
    props.submissionProps.status = 'missing'
    props.submissionProps.submission = null

    let tree = shallow(<Header {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders with an ungraded submission', () => {
    let props = _.cloneDeep(subProps)
    props.submissionProps.status = 'missing'
    props.assignmentSubmissionTypes = [ 'not_graded' ]

    let tree = shallow(<Header {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('anonymizes the avatar and name', () => {
    let tree = shallow(<Header {...subProps} anonymous />)
    expect(tree.find('Avatar').prop('userName')).toEqual('Student')
    expect(tree.find('[children="Student"]').exists()).toBe(true)
    expect(tree.find('[testID="header.context.button.4"]').prop('onPress')).toBeUndefined()
  })

  it('renders avatar and name', () => {
    let props = _.cloneDeep(subProps)
    props.submissionProps.name = 'Alice'
    let tree = shallow(<Header {...props} />)
    expect(tree.find('Avatar').prop('userName')).toEqual('Alice')
    expect(tree.find('[children="Alice"]').exists()).toBe(true)

    props.submissionProps.pronouns = 'She/Her'
    tree = shallow(<Header {...props} />)
    expect(tree.find('Avatar').prop('userName')).toEqual('Alice')
    expect(tree.find('[children="Alice (She/Her)"]').exists()).toBe(true)
  })

  it('closes the modal', () => {
    let tree = shallow(<Header {...subProps} />)
    tree.find('[testID="header.navigation-done"]').simulate('Press')
    expect(subProps.closeModal).toHaveBeenCalled()
  })

  it('navigates to the context card when name is pressed', () => {
    let tree = shallow(<Header {...subProps} />)
    tree.find('[testID="header.context.button.4"]').simulate('Press')
    expect(subProps.navigator.show).toHaveBeenCalledWith(
      `/courses/3/users/4`,
      { modal: true },
    )
  })

  it('doesnt show the group name when anonymous', () => {
    let tree = shallow(<Header {...groupProps} anonymous />)
    expect(tree).toMatchSnapshot()
  })

  it('opens student list when group is tapped', () => {
    let tree = shallow(<Header {...groupProps} />)
    tree.find('[testID="header.groupList.button.1"]').simulate('Press')
    expect(groupProps.navigator.show).toHaveBeenCalledWith(
      `/groups/1/users`,
      { modal: true },
      { courseID: '3' },
    )
  })

  it('renders the eye icon', () => {
    let tree = shallow(<Header {...subProps} />)
    let eye = tree.find('[testID="header.navigation-eye"]')
    expect(eye.length).toEqual(1)
  })

  it('navigates to post policy when tapping on the eye icon', () => {
    let navigator = { show: jest.fn() }
    let tree = shallow(
      <Header
        {...subProps}
        navigator={navigator}
      />
    )
    let eye = tree.find('[testID="header.navigation-eye"]')
    eye.simulate('press')
    expect(navigator.show).toHaveBeenCalledWith(
      '/courses/3/assignments/2/post_policy',
      { modal: true }
    )
  })
})

describe('mapStateToProps', () => {
  it('returns the correct data when there is no submission', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {
            data: templates.assignment({ anonymize_students: true }),
          },
        },
        submissions: {
          '1': {
            submission: {},
            pending: 0,
            error: null,
            selectedIndex: 3,
          },
        },
        courses: {},
      },
    })

    let dataProps = mapStateToProps(state, noSubProps)
    expect(dataProps).toMatchObject({
      anonymous: true,
    })
  })

  it('returns the correct data when there is a submission', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {
            data: templates.assignment({ anonymize_students: true }),
          },
        },
        submissions: {
          '1': {
            submission: {},
            pending: 0,
            error: null,
            selectedIndex: 3,
          },
        },
        courses: {},
      },
    })

    let dataProps = mapStateToProps(state, subProps)
    expect(dataProps).toMatchObject({
      anonymous: true,
    })
  })

  it('returns the correct data when the assignment is for an anonymous quiz', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {
            data: templates.assignment({ id: '2', quiz_id: '1' }),
          },
        },
        quizzes: {
          '1': {
            data: templates.quiz({ id: '1', anonymous_submissions: true }),
          },
        },
        submissions: {
          '1': {
            submission: {},
            pending: 0,
            error: null,
            selectedIndex: 3,
          },
        },
        courses: {
          '3': {},
        },
      },
    })

    let dataProps = mapStateToProps(state, subProps)
    expect(dataProps).toMatchObject({
      anonymous: true,
    })
  })

  it('returns the correct data when the assignment has anonymous grading turned on', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {
            data: templates.assignment({ id: '2', anonymize_students: true }),
          },
        },
        submissions: {
          '1': {
            submission: {},
            pending: 0,
            error: null,
            selectedIndex: 3,
          },
        },
        courses: {
          '3': {},
        },
      },
    })

    let dataProps = mapStateToProps(state, subProps)
    expect(dataProps).toMatchObject({
      anonymous: true,
    })
  })
})
