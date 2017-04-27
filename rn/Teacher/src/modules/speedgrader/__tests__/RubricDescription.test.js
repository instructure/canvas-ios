// @flow

import React from 'react'
import { RubricDescription, mapStateToProps } from '../RubricDescription'
import renderer from 'react-test-renderer'

jest.unmock('ScrollView')

const templates = {
  ...require('../../../__templates__/react-native-navigation'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../api/canvas-api/__templates__/rubric'),
  ...require('../../../api/canvas-api/__templates__/assignments'),
}

let ownProps = {
  assignmentID: '1',
  rubricID: '1',
  navigator: templates.navigator(),
}

let defaultProps = {
  ...ownProps,
  description: 'A satisfactory description',
}

describe('RubricDescription', () => {
  beforeEach(() => jest.resetAllMocks())

  it('properly sets navigator event callback', () => {
    let tree = renderer.create(
      <RubricDescription {...defaultProps} />
    )

    expect(defaultProps.navigator.setOnNavigatorEvent).toHaveBeenCalledWith(tree.getInstance().onNavigatorEvent)
  })

  it('calls dismiss modal when the done button is pressed', () => {
    let tree = renderer.create(
      <RubricDescription {...defaultProps} />
    )

    let instance = tree.getInstance()
    instance.onNavigatorEvent({
      type: 'NavBarButtonPress',
      id: 'done',
    })

    expect(defaultProps.navigator.dismissModal).toHaveBeenCalled()
  })

  it('sets the title of the view', () => {
    renderer.create(
      <RubricDescription {...defaultProps} />
    )

    expect(defaultProps.navigator.setTitle).toHaveBeenCalled()
  })

  it('renders', () => {
    let tree = renderer.create(
      <RubricDescription {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })
})

describe('mapStateToProps', () => {
  it('returns an empty description when there is no rubric', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '1': {
            data: templates.assignment({
              id: '1',
            }),
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props.description).toEqual('')
  })

  it('returns the rubric description whent here is a rubric', () => {
    let rubric = templates.rubric({ id: '1' })
    let state = templates.appState({
      entities: {
        assignments: {
          '1': {
            data: templates.assignment({
              id: '1',
              rubric: [rubric],
            }),
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props.description).toEqual(rubric.long_description)
  })
})
