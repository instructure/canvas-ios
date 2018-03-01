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
import _ from 'lodash'
import React from 'react'
import { Header, mapStateToProps } from '../Header'

const templates = {
  ...require('../../../../__templates__/submissions'),
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/assignments'),
  ...require('../../../../__templates__/quiz'),
}

let noSubProps = {
  submissionID: null,
  assignmentID: '2',
  courseID: '3',
  userID: '4',
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

  it('anonymizes the avatar and name', () => {
    let tree = shallow(<Header {...subProps} anonymous />)
    expect(tree).toMatchSnapshot()
  })

  it('closes the modal', () => {
    let tree = shallow(<Header {...subProps} />)
    tree.find('[testID="header.navigation-done"]').simulate('Press')
    expect(subProps.closeModal).toHaveBeenCalled()
  })

  it('navigates to the context card when name is pressed', () => {
    let tree = shallow(<Header {...subProps} />)
    tree.find('[testID="header.context.button"]').simulate('Press')
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
    tree.find('[testID="header.groupList.button"]').simulate('Press')
    expect(groupProps.navigator.show).toHaveBeenCalledWith(
      `/groups/1/users`,
      { modal: true },
      { courseID: '3' },
    )
  })
})

describe('mapStateToProps', () => {
  it('returns the correct data when there is no submission', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {
            anonymousGradingOn: true,
            data: {},
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
            anonymousGradingOn: true,
            data: {},
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
            anonymousGradingOn: false,
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
        courses: {},
      },
    })

    let dataProps = mapStateToProps(state, subProps)
    expect(dataProps).toMatchObject({
      anonymous: true,
    })
  })

  it('returns the correct data when the course has anonymous grading turned on', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {
            anonymousGradingOn: false,
            data: templates.assignment({ id: '2' }),
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
          '3': {
            enabledFeatures: ['anonymous_grading'],
          },
        },
      },
    })

    let dataProps = mapStateToProps(state, subProps)
    expect(dataProps).toMatchObject({
      anonymous: true,
    })
  })
})
