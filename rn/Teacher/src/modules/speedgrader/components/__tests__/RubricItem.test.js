//
// Copyright (C) 2017-present Instructure, Inc.
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

// @flow

import React from 'react'
import { AlertIOS, AccessibilityInfo, ActionSheetIOS } from 'react-native'
import RubricItem from '../RubricItem'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'
import { shallow } from 'enzyme'
import * as templates from '../../../../__templates__'

jest.mock('../../../../common/components/CircleToggle', () => 'CircleToggle')
jest.mock('TouchableOpacity', () => 'TouchableOpacity')
jest.mock('AlertIOS', () => ({
  prompt: jest.fn(),
}))
jest.mock('ActionSheetIOS', () => ({
  showActionSheetWithOptions: jest.fn(),
}))

let defaultProps = {
  rubricItem: templates.rubric(),
  grade: { comments: '' },
  showDescription: jest.fn(),
  changeRating: jest.fn(),
  openCommentKeyboard: jest.fn(),
  deleteComment: jest.fn(),
  freeFormCriterionComments: false,
}

describe('RubricItem', () => {
  beforeEach(() => jest.clearAllMocks())

  it('renders', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('shows the text for not impacting a score if `ignore_for_scoring` is true', () => {
    let props = {
      ...defaultProps,
      rubricItem: templates.rubric({ ignore_for_scoring: true }),
    }
    let tree = shallow(<RubricItem {...props} />)
    expect(tree.find(`[testID='rubric-item.${props.rubricItem.id}-no-score']`).length).toEqual(1)
  })

  it('renders with free form', () => {
    let props = {
      ...defaultProps,
      freeFormCriterionComments: true,
    }
    let tree = renderer.create(
      <RubricItem {...props} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders an already selected grade', () => {
    let props = {
      ...defaultProps,
      grade: {
        points: 10,
        rating_id: '3',
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

  it('removes a selection when a selected circle is pressed', () => {
    let props = {
      ...defaultProps,
      grade: {
        points: 10,
        rating_id: '3',
        comments: '',
      },
    }
    let tree = renderer.create(
      <RubricItem {...props} />
    )

    let button = explore(tree.toJSON()).selectByID(`rubric-item.points-3`) || {}
    expect(button.props.on).toEqual(true)
    button.props.onPress()

    button = explore(tree.toJSON()).selectByID(`rubric-item.points-3`) || {}
    expect(button.props.on).toEqual(false)
  })

  it('calls changeRating with the id, points, and rating_id', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()

    const { id } = defaultProps.rubricItem.ratings[0]
    let button = explore(tree).selectByID(`rubric-item.points-${id}`) || {}
    button.props.onPress(0, id)

    expect(defaultProps.changeRating).toHaveBeenCalledWith('2', 0, id)
  })

  it('gets the value from prompting for a custom value', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByProp('testID', `rubric-item.customize-grade-${defaultProps.rubricItem.id}`).pop()
    button.props.onPress()

    expect(AlertIOS.prompt).toHaveBeenCalled()
    AlertIOS.prompt.mock.calls[0][2][1].onPress('12')
    expect(defaultProps.changeRating).toHaveBeenCalledWith(defaultProps.rubricItem.id, 12, undefined)
    expect(AccessibilityInfo.setAccessibilityFocus).toHaveBeenCalled()
  })

  it('refocuses the customize button on cancel of the prompt', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByProp('testID', `rubric-item.customize-grade-${defaultProps.rubricItem.id}`).pop()
    button.props.onPress()

    expect(AlertIOS.prompt).toHaveBeenCalled()
    AlertIOS.prompt.mock.calls[0][2][0].onPress()
    expect(AccessibilityInfo.setAccessibilityFocus).toHaveBeenCalled()
  })

  it('will remove the selected value if it is already set', () => {
    let props = {
      ...defaultProps,
      grade: {
        points: 1234,
        comments: '',
      },
    }
    let component = renderer.create(
      <RubricItem {...props} />
    )

    let button = explore(component.toJSON()).selectByProp('testID', `rubric-item.customize-grade-${defaultProps.rubricItem.id}`).pop()
    button.props.onPress()
    expect(component.getInstance().state.selectedPoints).toEqual(null)
  })

  it('will call openCommentKeyboard when the add comment button is pressed', () => {
    let props = {
      ...defaultProps,
      freeFormCriterionComments: true,
    }
    let tree = renderer.create(
      <RubricItem {...props} />
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

    // $FlowFixMe
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

    // $FlowFixMe
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

    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](0)
    expect(defaultProps.openCommentKeyboard).toHaveBeenCalledWith(defaultProps.rubricItem.id)
  })

  it('calls show tooltip with the rating description', () => {
    const showToolTip = jest.fn()
    let tree = renderer.create(
      <RubricItem {...defaultProps} showToolTip={showToolTip} />
    ).toJSON()

    let button = explore(tree).selectByID(`rubric-item.points-${defaultProps.rubricItem.ratings[0].id}`) || {}
    button.props.onLongPress(defaultProps.rubricItem.ratings[0].id, { x: 8, y: 9, width: 10, height: 44 })

    expect(showToolTip).toHaveBeenCalledWith(
      { x: 13, y: 9 },
      defaultProps.rubricItem.ratings[0].description
    )
  })

  it('calls dismissToolTip onPressOut', () => {
    const dismissToolTip = jest.fn()
    let tree = renderer.create(
      <RubricItem {...defaultProps} dismissToolTip={dismissToolTip} />
    ).toJSON()

    let button = explore(tree).selectByID(`rubric-item.points-${defaultProps.rubricItem.ratings[0].id}`) || {}
    button.props.onPressOut()

    expect(dismissToolTip).toHaveBeenCalled()
  })
})
