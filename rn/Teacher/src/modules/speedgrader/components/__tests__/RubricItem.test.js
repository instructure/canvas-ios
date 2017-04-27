// @flow

import React from 'react'
import RubricItem from '../RubricItem'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

jest.mock('react-native-button', () => 'Button')

const templates = {
  ...require('../../../../api/canvas-api/__templates__/rubric'),
}

let defaultProps = {
  rubricItem: templates.rubric(),
  showDescription: jest.fn(),
}

describe('RubricItem', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
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
})
