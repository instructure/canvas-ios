// @flow

import React from 'react'
import { Speedgrader, mapStateToProps } from '../Speedgrader'
import renderer from 'react-test-renderer'

const templates = {
  ...require('../../../api/canvas-api/__templates__/submissions'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/react-native-navigation'),
}

let ownProps = {
  assignmentID: '1',
  userID: '1',
  courseID: '1',
}

let defaultProps = {
  ...ownProps,
  pending: false,
  refreshing: false,
  refresh: jest.fn(),
  refreshSubmissions: jest.fn(),
  navigator: templates.navigator(),
  submissions: [templates.submissionHistory()],
}

describe('Speedgrader', () => {
  it('renders', () => {
    let tree = renderer.create(
      <Speedgrader {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
    expect(defaultProps.navigator.setTitle).toHaveBeenCalledWith({
      title: 'Speedgrader',
    })
    expect(defaultProps.navigator.setOnNavigatorEvent).toHaveBeenCalled()
  })

  it('shows the loading spinner when there are no submissions', () => {
    let tree = renderer.create(
      <Speedgrader {...defaultProps} submissions={undefined} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('shows the loading spinner when pending and not refreshing', () => {
    let tree = renderer.create(
      <Speedgrader {...defaultProps} pending={true} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('calls dismissModal when done is pressed', () => {
    let tree = renderer.create(
      <Speedgrader {...defaultProps} />
    )

    tree.getInstance().onNavigatorEvent({
      type: 'NavBarButtonPress',
      id: 'done',
    })

    expect(defaultProps.navigator.dismissModal).toHaveBeenCalled()
  })
})

describe('mapStateToProps', () => {
  it('returns pending false when there is no assignment', () => {
    let appState = templates.appState()

    let props = mapStateToProps(appState, ownProps)
    expect(props.pending).toBeFalsy()
    expect(props.submissions).toBeFalsy()
  })

  it('returns pending true when the assignment pending state indicates there are pending actions', () => {
    let appState = templates.appState({
      entities: {
        assignments: {
          '1': {
            submissions: {
              pending: 1,
              refs: [],
            },
          },
        },
      },
    })

    let props = mapStateToProps(appState, ownProps)
    expect(props.pending).toBeTruthy()
  })

  it('returns the submissions if there are some', () => {
    let appState = templates.appState({
      entities: {
        assignments: {
          '1': {
            submissions: {
              pending: 0,
              refs: ['1'],
            },
          },
        },
        submissions: {
          '1': templates.submissionHistory(),
        },
      },
    })

    let props = mapStateToProps(appState, ownProps)
    let submissions = props.submissions || []
    expect(submissions.length).toEqual(1)
    expect(submissions[0]).toEqual(appState.entities.submissions['1'])
  })
})
