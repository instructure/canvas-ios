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

import React from 'react'
import { AlertIOS } from 'react-native'
import {
  SubmissionList,
  refreshSubmissionList,
  shouldRefresh,
} from '../SubmissionList'
import renderer from 'react-test-renderer'
import setProps from '../../../../../test/helpers/setProps'
import cloneDeep from 'lodash/cloneDeep'

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../__templates__/submission-props'),
  ...require('../../../../__templates__/course'),
}

jest
  .mock('../../../../routing')
  .mock('AlertIOS', () => ({
    alert: jest.fn(),
  }))
  .mock('knuth-shuffle-seeded', () => jest.fn())

const submissionProps: Array<SubmissionDataProps> = [
  template.submissionProps({
    name: 'S1',
    status: 'none',
    grade: 'not_submitted',
    userID: '1',
  }),
  template.submissionProps({
    name: 'S2',
    status: 'none',
    grade: 'excused',
    userID: '2',
  }),
  template.submissionProps({
    name: 'S3',
    status: 'late',
    grade: 'ungraded',
    userID: '3',
  }),
  template.submissionProps({
    name: 'S4',
    status: 'submitted',
    grade: 'A-',
    userID: '4',
  }),
]

const props = {
  submissions: submissionProps,
  pending: false,
  courseID: '12',
  assignmentID: '32',
  courseColor: '#ddd',
  courseName: 'fancy name',
  refreshSubmissions: jest.fn(),
  refreshEnrollments: jest.fn(),
  refreshGroupsForCourse: jest.fn(),
  shouldRefresh: false,
  refreshing: false,
  refresh: jest.fn(),
  anonymous: false,
  muted: false,
  assignmentName: 'Blah',
  course: template.course(),
  groupAssignment: null,
}

beforeEach(() => jest.resetAllMocks())

test('SubmissionList loaded', () => {
  const tree = renderer.create(
    <SubmissionList {...props} navigator={template.navigator()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('SubmissionList shows loading indicator', () => {
  const tree = renderer.create(
    <SubmissionList {...props} navigator={template.navigator()} pending={true} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('SubmissionList loaded with nothing and it should not explode, and then props should be set and it should be great', () => {
  const tree = renderer.create(
    <SubmissionList {...props} navigator={template.navigator()} />
  )
  expect(tree).toBeDefined()
  setProps(tree, props)
  expect(tree.getInstance().state.submissions).toEqual(props.submissions)
})

test('SubmissionList select filter function', () => {
  const expandedProps = cloneDeep(props)
  expandedProps.submissions = expandedProps.submissions.concat([
    template.submissionProps({
      name: 'S5',
      status: 'submitted',
      grade: '60',
      score: 60,
      userID: '5',
    }),
    template.submissionProps({
      name: 'S6',
      status: 'submitted',
      grade: '30',
      score: 30,
      userID: '6',
    }),
  ])

  const instance = renderer.create(
    <SubmissionList { ...expandedProps } navigator={template.navigator()} />
  ).getInstance()

  instance.updateFilter({
    filter: instance.filterOptions[0],
  })
  expect(instance.state.submissions).toMatchObject(expandedProps.submissions)

  instance.updateFilter({
    filter: instance.filterOptions[1],
  })
  expect(instance.state.submissions).toMatchObject([
    {
      status: 'late',
    },
  ])

  instance.updateFilter({
    filter: instance.filterOptions[2],
  })
  expect(instance.state.submissions).toMatchObject([
    {
      grade: 'not_submitted',
    },
  ])

  instance.updateFilter({
    filter: instance.filterOptions[3],
  })
  expect(instance.state.submissions).toMatchObject([
    {
      grade: 'ungraded',
    },
  ])

  instance.updateFilter({
    filter: instance.filterOptions[5],
    metadata: 50,
  })
  expect(instance.state.submissions).toMatchObject([
    {
      score: 30,
      status: 'submitted',
    },
  ])

  // Scored more than…
  instance.updateFilter({
    filter: instance.filterOptions[6],
    metadata: 50,
  })
  expect(instance.state.submissions).toMatchObject([
    {
      score: 60,
      status: 'submitted',
    },
  ])

  // Cancel
  instance.clearFilter()
  expect(instance.state.submissions).toMatchObject(expandedProps.submissions)
  instance.updateFilter({
    filter: instance.filterOptions[7],
  })
  expect(instance.state.submissions).toMatchObject(expandedProps.submissions)
})

test('SubmissionList renders correctly with graded filter', () => {
  const expandedProps = cloneDeep(props)
  expandedProps.submissions = expandedProps.submissions.concat([
    template.submissionProps({
      name: 'S5',
      status: 'graded',
      grade: '60',
      score: 60,
      userID: '5',
    }),
  ])

  expandedProps.filterType = 'graded'

  const tree = renderer.create(
    <SubmissionList {...expandedProps} navigator={template.navigator()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('SubmissionList renders correctly with ungraded filter', () => {
  const expandedProps = cloneDeep(props)
  expandedProps.submissions = expandedProps.submissions.concat([
    template.submissionProps({
      name: 'S6',
      status: 'submitted',
      grade: '70',
      score: 70,
      userID: '6',
    }),
  ])

  expandedProps.filterType = 'ungraded'

  const tree = renderer.create(
    <SubmissionList {...expandedProps} navigator={template.navigator()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('SubmissionList renders correctly with not_submitted filter', () => {
  const expandedProps = cloneDeep(props)
  expandedProps.submissions = expandedProps.submissions.concat([
    template.submissionProps({
      name: 'S7',
      status: 'none',
      grade: null,
      score: null,
      userID: '7',
    }),
  ])

  expandedProps.filterType = 'not_submitted'

  const tree = renderer.create(
    <SubmissionList {...expandedProps} navigator={template.navigator()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('should refresh', () => {
  expect(shouldRefresh(props)).toEqual(true)
})

test('should navigate to submission settings', () => {
  let navigator = template.navigator({
    show: jest.fn(),
  })

  const tree = renderer.create(
    <SubmissionList {...props} navigator={navigator} />
  )
  tree.getInstance().openSettings()

  expect(navigator.show).toHaveBeenCalledWith('/courses/12/assignments/32/submission_settings', { modal: true })
})

test('should navigate to a submission', () => {
  let submission = props.submissions[0]
  let navigator = template.navigator({
    show: jest.fn(),
  })
  const tree = renderer.create(
    <SubmissionList {...props} navigator={navigator} />
  )
  tree.getInstance().navigateToSubmission(1)(submission.userID)

  expect(navigator.show).toHaveBeenCalledWith(
    '/courses/12/assignments/32/submissions/1',
    { modal: true, modalPresentationStyle: 'fullscreen' },
    { selectedFilter: undefined, studentIndex: 1 }
  )
})

test('shows message compose with correct data', () => {
  const expandedProps = cloneDeep(props)
  expandedProps.submissions = expandedProps.submissions.concat([
    template.submissionProps({
      name: 'S5',
      status: 'submitted',
      grade: '60',
      score: 60,
      userID: '5',
    }),
    template.submissionProps({
      name: 'S6',
      status: 'submitted',
      grade: '30',
      score: 30,
      userID: '6',
    }),
  ])
  let navigator = template.navigator({
    show: jest.fn(),
  })
  const tree = renderer.create(
    <SubmissionList {...expandedProps} navigator={navigator} />
  )
  let instance = tree.getInstance()

  let expectSubjectToBeCorrect = (subject: string) => {
    instance.messageStudentsWho()
    expect(navigator.show).toHaveBeenCalledWith('/conversations/compose', { modal: true }, {
      recipients: instance.state.submissions.map((submission) => {
        return { id: submission.userID, name: submission.name, avatar_url: submission.avatarURL }
      }),
      subject: subject,
      course: expandedProps.course,
      canAddRecipients: false,
      onlySendIndividualMessages: true,
    })
  }
  expect(navigator.show).toHaveBeenCalledW

  it('handles all submissions', () => {
    instance.updateFilter({
      filter: instance.filterOptions[0],
    })
    expectSubjectToBeCorrect('All submissions - Blah')
  })

  it('handles late submissions', () => {
    instance.updateFilter({
      filter: instance.filterOptions[1],
    })
    expectSubjectToBeCorrect('Submitted late - Blah')
  })

  it('handles un-submissions', () => {
    instance.updateFilter({
      filter: instance.filterOptions[2],
    })
    expectSubjectToBeCorrect("Haven't submitted yet - Blah")
  })

  it('handles un-gradedness', () => {
    instance.updateFilter({
      filter: instance.filterOptions[3],
    })
    expectSubjectToBeCorrect("Haven't been graded - Blah")
  })

  it('handles graded', () => {
    instance.updateFilter({
      filter: instance.filterOptions[4],
    })
    expectSubjectToBeCorrect('Graded - Blah')
  })

  it('handles scored less than', () => {
    instance.updateFilter({
      filter: instance.filterOptions[5],
      metadata: 50,
    })
    expectSubjectToBeCorrect('Scored less than 50 - Blah')
  })

  it('handles scored more than', () => {
    instance.updateFilter({
      filter: instance.filterOptions[6],
      metadata: 50,
    })
    expectSubjectToBeCorrect('Scored more than 50 - Blah')
  })
})

test('should prevent going to speed grader when offline', () => {
  let submission = props.submissions[0]
  let navigator = template.navigator({
    show: jest.fn(),
  })
  let tree = renderer.create(
    <SubmissionList {...props} navigator={navigator} />
  )
  tree.getInstance().setState({ isConnected: false })
  tree.getInstance().navigateToSubmission(1)(submission.userID)

  expect(AlertIOS.alert).toHaveBeenCalled()
  expect(navigator.show).not.toHaveBeenCalled()
})

test('refreshSubmissionList', () => {
  refreshSubmissionList(props)
  expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID, false)
  expect(props.refreshEnrollments).toHaveBeenCalledWith(props.courseID)
})

test('refreshSubmissionList (group submissions)', () => {
  refreshSubmissionList({
    ...props,
    groupAssignment: { groupCategoryID: '2', gradeIndividually: false },
  })
  expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID,
  true)
  expect(props.refreshGroupsForCourse).toHaveBeenCalledWith(props.courseID)
})
