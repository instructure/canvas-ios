// @flow

import React from 'react'
import { AlertIOS, NativeModules, ActionSheetIOS } from 'react-native'
import RubricItem from '../RubricItem'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

jest.mock('../../../../common/components/CircleToggle', () => 'CircleToggle')
jest.mock('react-native-button', () => 'Button')
jest.mock('AlertIOS', () => ({
  prompt: jest.fn(),
}))
jest.mock('ActionSheetIOS', () => ({
  showActionSheetWithOptions: jest.fn(),
}))

const templates = {
  ...require('../../../../api/canvas-api/__templates__/rubric'),
}

let defaultProps = {
  rubricItem: templates.rubric(),
  grade: { comments: '' },
  showDescription: jest.fn(),
  changeRating: jest.fn(),
  openCommentKeyboard: jest.fn(),
  deleteComment: jest.fn(),
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

    let button = explore(tree.toJSON()).selectByID(`rubric-item.points-${defaultProps.rubricItem.id}`) || {}
    button.props.onPress()

    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('calls changeRating with the id and value', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID(`rubric-item.points-${defaultProps.rubricItem.ratings[0].id}`) || {}
    button.props.onPress(0)

    expect(defaultProps.changeRating).toHaveBeenCalledWith('2', 0)
  })

  it('gets the value from prompting for a custom value', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByProp('testID', `rubric-item.customize-grade-${defaultProps.rubricItem.id}`).pop()
    button.props.onPress()

    expect(AlertIOS.prompt).toHaveBeenCalled()
    AlertIOS.prompt.mock.calls[0][2][1].onPress('12')
    expect(defaultProps.changeRating).toHaveBeenCalledWith(defaultProps.rubricItem.id, 12)
    expect(NativeModules.NativeAccessibility.focusElement).toHaveBeenCalledWith(`rubric-item.customize-grade-${defaultProps.rubricItem.id}`)
  })

  it('refocuses the customize button on cancel of the prompt', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByProp('testID', `rubric-item.customize-grade-${defaultProps.rubricItem.id}`).pop()
    button.props.onPress()

    expect(AlertIOS.prompt).toHaveBeenCalled()
    AlertIOS.prompt.mock.calls[0][2][0].onPress()
    expect(NativeModules.NativeAccessibility.focusElement).toHaveBeenCalledWith(`rubric-item.customize-grade-${defaultProps.rubricItem.id}`)
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

    let button = explore(tree).selectByProp('testID', `rubric-item.customize-grade-${defaultProps.rubricItem.id}`).pop()
    button.props.onPress()

    expect(AlertIOS.prompt.mock.calls[0][4]).toEqual('1234')
  })

  it('will call openCommentKeyboard when the add comment button is pressed', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID(`rubric-item.add-comment-${defaultProps.rubricItem.id}`) || {}
    button.props.onPress()

    expect(defaultProps.openCommentKeyboard).toHaveBeenCalledWith(defaultProps.rubricItem.id)
  })

  it('will not show the add comment button and will show the comment if there is one', () => {
    let props = {
      ...defaultProps,
      grade: { comments: 'A comment' },
    }

    let tree = renderer.create(
      <RubricItem {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('Will open an action sheet when a rubric comment is pressed', () => {
    let props = {
      ...defaultProps,
      grade: { comments: 'A comment' },
    }

    let tree = renderer.create(
      <RubricItem {...props} />
    ).toJSON()

    let button = explore(tree).selectByID(`rubric-item.edit-comment-${defaultProps.rubricItem.id}`) || {}
    button.props.onPress()

    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
  })

  it('will do nothing when cancel is pressed in the edit action sheet', () => {
    let props = {
      ...defaultProps,
      grade: { comments: 'A comment' },
    }

    let tree = renderer.create(
      <RubricItem {...props} />
    ).toJSON()

    let button = explore(tree).selectByID(`rubric-item.edit-comment-${defaultProps.rubricItem.id}`) || {}
    button.props.onPress()

    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](2)
    expect(defaultProps.deleteComment).not.toHaveBeenCalled()
    expect(defaultProps.openCommentKeyboard).not.toHaveBeenCalled()
  })

  it('will call deleteComment when the delete option is pressed in the edit action sheet', () => {
    let props = {
      ...defaultProps,
      grade: { comments: 'A comment' },
    }

    let tree = renderer.create(
      <RubricItem {...props} />
    ).toJSON()

    let button = explore(tree).selectByID(`rubric-item.edit-comment-${defaultProps.rubricItem.id}`) || {}
    button.props.onPress()

    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](1)
    expect(defaultProps.deleteComment).toHaveBeenCalledWith(defaultProps.rubricItem.id)
  })

  it('will call openCommentKeyboard when the edit option is pressed in the edit action sheet', () => {
    let props = {
      ...defaultProps,
      grade: { comments: 'A comment' },
    }

    let tree = renderer.create(
      <RubricItem {...props} />
    ).toJSON()

    let button = explore(tree).selectByID(`rubric-item.edit-comment-${defaultProps.rubricItem.id}`) || {}
    button.props.onPress()

    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](0)
    expect(defaultProps.openCommentKeyboard).toHaveBeenCalledWith(defaultProps.rubricItem.id)
  })

  it('calls show tooltip with the rating description', () => {
    const showToolTip = jest.fn()
    let tree = renderer.create(
      <RubricItem {...defaultProps} showToolTip={showToolTip} />
    ).toJSON()

    let button = explore(tree).selectByID(`rubric-item.points-${defaultProps.rubricItem.ratings[0].id}`) || {}
    button.props.onLongPress(0, { x: 8, y: 9, width: 10, height: 44 })

    expect(showToolTip).toHaveBeenCalledWith(
      { x: 13, y: 9 },
      defaultProps.rubricItem.ratings[0].description
    )
  })
})
