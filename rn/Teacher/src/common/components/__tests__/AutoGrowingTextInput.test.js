// @flow

import React from 'react'
import AutoGrowingTextInput from '../AutoGrowingTextInput'
import renderer from 'react-test-renderer'

let defaultProps = {
  defaultHeight: 54,
  onContentSizeChange: jest.fn(),
}

describe('AutoGrowingTextInput', () => {
  beforeEach(() => jest.resetAllMocks())
  it('renders', () => {
    let tree = renderer.create(
      <AutoGrowingTextInput {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('adjusts the height when content size is updated', () => {
    let tree = renderer.create(
      <AutoGrowingTextInput {...defaultProps} />
    )

    let event = { nativeEvent: { contentSize: { height: 100 } } }

    tree.getInstance().updateContentSize(event)
    expect(tree.toJSON()).toMatchSnapshot()
    expect(defaultProps.onContentSizeChange).toHaveBeenCalledWith(event)
  })
})
