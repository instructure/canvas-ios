// @flow

import _ from 'lodash'
import React from 'react'
import { Header, mapStateToProps } from '../Header'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')

const templates = {
  ...require('../../../../api/canvas-api/__templates__/submissions'),
  ...require('../../../../redux/__templates__/app-state'),
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

describe('SpeedGraderHeader', () => {
  it('renders with no submission', () => {
    let tree = renderer.create(
      <Header {...noSubProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders with a submission', () => {
    let tree = renderer.create(
      <Header {...subProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders with a grade-only submission', () => {
    let props = _.cloneDeep(subProps)
    props.submissionProps.status = 'none'

    let tree = renderer.create(
      <Header {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders with an over-due grade-only submission', () => {
    let props = _.cloneDeep(subProps)
    props.submissionProps.status = 'missing'
    props.submissionProps.submission = null

    let tree = renderer.create(
      <Header {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('anonymizes the avatar and name', () => {
    let tree = renderer.create(<Header {...subProps} anonymous={true} />)
    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('closes the modal', () => {
    let tree = renderer.create(
      <Header {...subProps} />
    ).toJSON()

    const doneButton = explore(tree).selectByID('header.navigation-done') || {}
    doneButton.props.onPress()
    expect(subProps.closeModal).toHaveBeenCalled()
  })

  it('doesnt show the student name when anonymous', () => {
    let tree = renderer.create(
      <Header {...subProps} anonymous={true} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })
})

describe('mapStateToProps', () => {
  it('returns the correct data when there is no submission', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {
            anonymousGradingOn: true,
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
      },
    })

    let dataProps = mapStateToProps(state, subProps)
    expect(dataProps).toMatchObject({
      anonymous: true,
    })
  })
})
