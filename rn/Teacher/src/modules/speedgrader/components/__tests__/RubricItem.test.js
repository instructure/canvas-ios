// @flow

import React from 'react'
import { AlertIOS } from 'react-native'
import RubricItem from '../RubricItem'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

jest.mock('react-native-button', () => 'Button')
jest.mock('AlertIOS', () => ({
  prompt: jest.fn(),
}))

const templates = {
  ...require('../../../../api/canvas-api/__templates__/rubric'),
}

let defaultProps = {
  rubricItem: templates.rubric(),
  grade: { comments: '' },
  showDescription: jest.fn(),
  changeRating: jest.fn(),
}

describe('RubricItem', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders an already selected grade', () => {
    let props = {
      ...defaultProps,
      grade: {
        points: 10,
        comments: '',
      },
    }
    let tree = renderer.create(
      <RubricItem {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders the selected custom grade', () => {
    let props = {
      ...defaultProps,
      grade: {
        points: 12,
        comments: '',
      },
    }
    let tree = renderer.create(
      <RubricItem {...props} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('calls showDescription when the button is pressed', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('rubric-item.description') || {}
    button.props.onPress()

    expect(defaultProps.showDescription).toHaveBeenCalledWith(defaultProps.rubricItem.id)
  })

  it('changes the currently selected value when a circle is pressed', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    )

    let button = explore(tree.toJSON()).selectByID('circle-button') || {}
    button.props.onPress()

    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('calls changeRating with the id and value', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('circle-button') || {}
    button.props.onPress()

    expect(defaultProps.changeRating).toHaveBeenCalledWith('2', 10)
  })

  it('gets the value from prompting for a custom value', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByProp('testID', 'circle-button').pop()
    button.props.onPress()

    expect(AlertIOS.prompt).toHaveBeenCalled()
    AlertIOS.prompt.mock.calls[0][2]('12')
    expect(defaultProps.changeRating).toHaveBeenCalledWith(defaultProps.rubricItem.id, 12)
  })

  it('will call prompt with a default value if there is an existing custom grade', () => {
    let props = {
      ...defaultProps,
      grade: {
        points: 1234,
        comments: '',
      },
    }
    let tree = renderer.create(
      <RubricItem {...props} />
    ).toJSON()

    let button = explore(tree).selectByProp('testID', 'circle-button').pop()
    button.props.onPress()

    expect(AlertIOS.prompt.mock.calls[0][4]).toEqual('1234')
  })
})
