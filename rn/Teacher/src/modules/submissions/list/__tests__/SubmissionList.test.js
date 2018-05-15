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
import { AlertIOS } from 'react-native'
import {
  SubmissionList,
  refreshSubmissionList,
  shouldRefresh,
} from '../SubmissionList'
import renderer from 'react-test-renderer'
import cloneDeep from 'lodash/cloneDeep'
import defaultFilterOptions, { updateFilterSelection } from '../../../filter/filter-options'

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../__templates__/submission-props'),
  ...require('../../../../__templates__/course'),
  ...require('../../../../__templates__/section'),
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
  refreshSections: jest.fn(),
  shouldRefresh: false,
  refreshing: false,
  refresh: jest.fn(),
  anonymous: false,
  muted: false,
  assignmentName: 'Blah',
  groupAssignment: null,
  sections: [template.section()],
  getCourseEnabledFeatures: jest.fn(),
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

  instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'all'))
  expect(instance.state.filter(instance.props.submissions)).toMatchObject(expandedProps.submissions)

  instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'late'))
  expect(instance.state.filter(instance.props.submissions)).toMatchObject([
    {
      status: 'late',
    },
  ])

  instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'not_submitted'))
  expect(instance.state.filter(instance.props.submissions)).toMatchObject([
    {
      grade: 'not_submitted',
    },
  ])

  instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'ungraded'))
  expect(instance.state.filter(instance.props.submissions)).toMatchObject([
    {
      grade: 'ungraded',
    },
  ])

  instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'lessthan', 50))
  expect(instance.state.filter(instance.props.submissions)).toMatchObject([
    {
      score: 30,
      status: 'submitted',
    },
  ])

  instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'morethan', 50))
  expect(instance.state.filter(instance.props.submissions)).toMatchObject([
    {
      score: 60,
      status: 'submitted',
    },
  ])

  // Cancel
  instance.applyFilter(defaultFilterOptions())
  expect(instance.state.filter(instance.props.submissions)).toMatchObject(expandedProps.submissions)
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

test('SubmissionList renders correctly with empty list', () => {
  const expandedProps = cloneDeep(props)
  expandedProps.submissions = []

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
  let instance = tree.getInstance()

  instance.navigateToSubmission(1)(submission.userID)
  expect(navigator.show).toHaveBeenCalledWith(
    '/courses/12/assignments/32/submissions/1',
    { modal: true, modalPresentationStyle: 'fullscreen' },
    { filter: instance.state.filter, studentIndex: 1 }
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

  it('handles all submissions', () => {
    instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'all'))
    expectSubjectToBeCorrect('All submissions - Blah')
  })

  it('handles late submissions', () => {
    instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'late'))
    expectSubjectToBeCorrect('Submitted late - Blah')
  })

  it('handles un-submissions', () => {
    instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'not_submitted'))
    expectSubjectToBeCorrect("Haven't submitted yet - Blah")
  })

  it('handles un-gradedness', () => {
    instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'ungraded'))
    expectSubjectToBeCorrect("Haven't been graded - Blah")
  })

  it('handles graded', () => {
    instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'graded'))
    expectSubjectToBeCorrect('Graded - Blah')
  })

  it('handles scored less than', () => {
    instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'lessthan', 50))
    expectSubjectToBeCorrect('Scored less than 50 - Blah')
  })

  it('handles scored more than', () => {
    instance.applyFilter(updateFilterSelection(instance.state.filterOptions, 'morethan', 50))
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

test('refreshSubmissionList (missing groups data)', () => {
  refreshSubmissionList({
    ...props,
    isMissingGroupsData: true,
    isGroupGradedAssignment: false,
  })
  expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID,
    true)
  expect(props.refreshGroupsForCourse).toHaveBeenCalledWith(props.courseID)
})

test('refreshSubmissionList (group graded submissions)', () => {
  refreshSubmissionList({
    ...props,
    isMissingGroupsData: false,
    isGroupGradedAssignment: true,
  })
  expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID,
    true)
  expect(props.refreshGroupsForCourse).toHaveBeenCalledWith(props.courseID)
})
