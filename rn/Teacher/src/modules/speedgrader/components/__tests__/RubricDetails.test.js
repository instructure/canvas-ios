// @flow

import React from 'react'
import { RubricDetails, mapStateToProps } from '../RubricDetails'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'
import { registerScreens } from '../../../../routing/register-screens'

registerScreens({})
jest.mock('react-native-button', () => 'Button')

const templates = {
  ...require('../../../../api/canvas-api/__templates__/rubric'),
  ...require('../../../../redux/__templates__/app-state'),
}

let ownProps = {
  assignmentID: '1',
  courseID: '1',
  submissionID: '1',
  showModal: jest.fn(),
}

let defaultProps = {
  ...ownProps,
  rubricItems: [templates.rubric()],
  rubricSettings: templates.rubricSettings(),
  rubricAssessment: templates.rubricAssessment(),
}

describe('Rubric', () => {
  it('doesnt render anything when there is no rubric', () => {
    let props = {
      ...defaultProps,
      rubricItems: null,
    }
    let tree = renderer.create(
      <RubricDetails {...props} />
    ).toJSON()

    expect(tree).toBeNull()
  })

  it('renders a rubric', () => {
    let tree = renderer.create(
      <RubricDetails {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('calls showModal with the proper route when a view description is pressed', () => {
    let tree = renderer.create(
      <RubricDetails {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('rubric-item.description') || {}
    button.props.onPress()

    expect(defaultProps.showModal).toHaveBeenCalledWith({
      screen: '(/api/v1)/courses/:courseID/assignments/:assignmentID/rubrics/:rubricID/description',
      passProps: {
        courseID: '1',
        assignmentID: '1',
        rubricID: defaultProps.rubricItems[0].id,
      },
    })
  })

  it('has the correct score', () => {
    let tree = renderer.create(
      <RubricDetails {...defaultProps} />
    )

    tree.getInstance().setState({ ratings: { '2': 10 } })

    expect(tree.toJSON()).toMatchSnapshot()
  })
})

describe('mapStateToProps', () => {
  it('gives us the rubric items if there are any', () => {
    let rubricItems = { yo: 'yo' }
    let rubricSettings = { yoyo: 'yoyo' }
    let state = templates.appState({
      entities: {
        assignments: {
          '1': {
            data: {
              rubric: rubricItems,
              rubric_settings: rubricSettings,
            },
          },
        },
        submissions: {},
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props.rubricItems).toEqual(rubricItems)
    expect(props.rubricSettings).toEqual(rubricSettings)
  })

  it('returns rubric assessments when there are some', () => {
    let rubricAssessment = {}
    let state = templates.appState({
      entities: {
        assignments: {
          '1': {
            data: {},
          },
        },
        submissions: {
          '1': {
            submission: {
              rubric_assessment: rubricAssessment,
            },
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props.rubricAssessment).toEqual(rubricAssessment)
  })

  it('returns null when there is no submission', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '1': {
            data: {},
          },
        },
        submissions: {},
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props.rubricAssessment).toBeNull()
  })
})
