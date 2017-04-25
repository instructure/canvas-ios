// @flow

import React from 'react'
import { Header } from '../Header'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

const templates = {
  ...require('../../../../api/canvas-api/__templates__/submissions'),
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
    submission: templates.submissionHistory([{ id: '1', grade: null }]),
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

  it('closes the modal', () => {
    let tree = renderer.create(
      <Header {...subProps} />
    ).toJSON()

    const doneButton = explore(tree).selectByID('header.navigation-done') || {}
    doneButton.props.onPress()
    expect(subProps.closeModal).toHaveBeenCalled()
  })
})
