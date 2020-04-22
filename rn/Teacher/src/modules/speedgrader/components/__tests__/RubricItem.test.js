//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import { shallow } from 'enzyme'
import React from 'react'
import { Alert, AccessibilityInfo, ActionSheetIOS } from 'react-native'
import RubricItem from '../RubricItem'
import * as templates from '../../../../__templates__'

jest.mock('react-native/Libraries/Alert/Alert', () => ({
  prompt: jest.fn(),
}))
jest.mock('react-native/Libraries/ActionSheetIOS/ActionSheetIOS', () => ({
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
    let tree = shallow(<RubricItem {...defaultProps} />)
    expect(tree.find('Text').first().prop('children')).toBe(defaultProps.rubricItem.description)
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
    let tree = shallow(<RubricItem {...props} />)
    let button = tree.find(`[testID='rubric-item.add-comment-${props.rubricItem.id}']`)
    expect(button.prop('children')).toBe('Add Comment')
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
    let tree = shallow(<RubricItem {...props} />)
    expect(tree.find(`[testID='rubric-item.points-3']`).prop('on')).toBe(true)
    expect(tree.find(`[testID='rubric-item.points-3']`).prop('children')).toBe('10')
  })

  it('renders a custom grade on a selected rating', () => {
    let props = {
      ...defaultProps,
      grade: {
        points: 8,
        rating_id: '3',
        comments: '',
      },
    }
    let tree = shallow(<RubricItem {...props} />)
    expect(tree.find(`[testID='rubric-item.points-3']`).prop('on')).toBe(true)
    expect(tree.find(`[testID='rubric-item.points-3']`).prop('children')).toBe('8')
  })

  it('renders the selected custom grade', () => {
    let props = {
      ...defaultProps,
      grade: {
        points: 12,
        comments: '',
      },
    }
    let tree = shallow(<RubricItem {...props} />)
    let button = tree.find(`[testID='rubric-item.customize-grade-${props.rubricItem.id}']`)
    expect(button.prop('children')).toBe('12')
  })

  it('calls showDescription when the button is pressed', () => {
    let tree = shallow(<RubricItem {...defaultProps} />)
    tree.find(`[testID='rubric-item.description']`).simulate('Press')
    expect(defaultProps.showDescription).toHaveBeenCalledWith(defaultProps.rubricItem.id)
  })

  it('changes the currently selected value when a circle is pressed', () => {
    let tree = shallow(<RubricItem {...defaultProps} />)
    tree.find(`[testID='rubric-item.points-2']`).simulate('Press')
    expect(defaultProps.changeRating).toHaveBeenCalled()
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
    let tree = shallow(<RubricItem {...props} />)
    expect(tree.find(`[testID='rubric-item.points-3']`).prop('on')).toBe(true)
    tree.find(`[testID='rubric-item.points-3']`).simulate('Press')
    expect(tree.find(`[testID='rubric-item.points-3']`).prop('on')).toBe(false)
  })

  it('gets the value from prompting for a custom value', () => {
    let tree = shallow(<RubricItem {...defaultProps} />)
    tree.find(`[testID='rubric-item.customize-grade-${defaultProps.rubricItem.id}']`)
      .simulate('Press')

    expect(Alert.prompt).toHaveBeenCalled()
    expect(Alert.prompt.mock.calls[0][5]).toEqual('decimal-pad')
    Alert.prompt.mock.calls[0][2][1].onPress('12')
    expect(defaultProps.changeRating).toHaveBeenCalledWith(defaultProps.rubricItem.id, 12, undefined)
    expect(AccessibilityInfo.setAccessibilityFocus).toHaveBeenCalled()
  })

  it('refocuses the customize button on cancel of the prompt', () => {
    let tree = shallow(<RubricItem {...defaultProps} />)
    tree.find(`[testID='rubric-item.customize-grade-${defaultProps.rubricItem.id}']`)
      .simulate('Press')

    expect(Alert.prompt).toHaveBeenCalled()
    Alert.prompt.mock.calls[0][2][0].onPress()
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
    let tree = shallow(<RubricItem {...props} />)
    tree.find(`[testID='rubric-item.customize-grade-${props.rubricItem.id}']`)
      .simulate('Press')
    expect(tree.state('selectedPoints')).toBe(null)
  })

  it('will call openCommentKeyboard when the add comment button is pressed', () => {
    let props = {
      ...defaultProps,
      freeFormCriterionComments: true,
    }
    let tree = shallow(<RubricItem {...props} />)
    tree.find(`[testID='rubric-item.add-comment-${props.rubricItem.id}']`)
      .simulate('Press')
    expect(defaultProps.openCommentKeyboard).toHaveBeenCalledWith(defaultProps.rubricItem.id)
  })

  it('will not show the add comment button and will show the comment if there is one', () => {
    let props = {
      ...defaultProps,
      grade: { comments: 'A comment' },
    }
    let tree = shallow(<RubricItem {...props} />)
    let button = tree.find(`[testID='rubric-item.add-comment-${props.rubricItem.id}']`)
    expect(button.exists()).toBe(false)
  })

  it('will open an action sheet when a rubric comment is pressed', () => {
    let props = {
      ...defaultProps,
      grade: { comments: 'A comment' },
    }
    let tree = shallow(<RubricItem {...props} />)
    tree.find(`[testID='rubric-item.edit-comment-${props.rubricItem.id}']`)
      .simulate('Press')
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
  })

  it('will do nothing when cancel is pressed in the edit action sheet', () => {
    let props = {
      ...defaultProps,
      grade: { comments: 'A comment' },
    }
    let tree = shallow(<RubricItem {...props} />)
    tree.find(`[testID='rubric-item.edit-comment-${props.rubricItem.id}']`)
      .simulate('Press')

    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](2)
    expect(defaultProps.deleteComment).not.toHaveBeenCalled()
    expect(defaultProps.openCommentKeyboard).not.toHaveBeenCalled()
  })

  it('will call deleteComment when the delete option is pressed in the edit action sheet', () => {
    let props = {
      ...defaultProps,
      grade: { comments: 'A comment' },
    }
    let tree = shallow(<RubricItem {...props} />)
    tree.find(`[testID='rubric-item.edit-comment-${props.rubricItem.id}']`)
      .simulate('Press')

    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](1)
    expect(defaultProps.deleteComment).toHaveBeenCalledWith(defaultProps.rubricItem.id)
  })

  it('will call openCommentKeyboard when the edit option is pressed in the edit action sheet', () => {
    let props = {
      ...defaultProps,
      grade: { comments: 'A comment' },
    }
    let tree = shallow(<RubricItem {...props} />)
    tree.find(`[testID='rubric-item.edit-comment-${props.rubricItem.id}']`)
      .simulate('Press')

    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](0)
    expect(defaultProps.openCommentKeyboard).toHaveBeenCalledWith(defaultProps.rubricItem.id)
  })

  it('calls show tooltip with the rating description', () => {
    const showToolTip = jest.fn()
    let tree = shallow(<RubricItem {...defaultProps} showToolTip={showToolTip} />)
    tree.find(`[testID='rubric-item.points-${defaultProps.rubricItem.ratings[0].id}']`)
      .simulate('LongPress', defaultProps.rubricItem.ratings[0].id, { x: 8, y: 9, width: 10, height: 44 })

    expect(showToolTip).toHaveBeenCalledWith(
      { x: 13, y: 9 },
      defaultProps.rubricItem.ratings[0].description
    )
  })

  it('calls dismissToolTip onPressOut', () => {
    const dismissToolTip = jest.fn()
    let tree = shallow(<RubricItem {...defaultProps} dismissToolTip={dismissToolTip} />)
    tree.find(`[testID='rubric-item.points-${defaultProps.rubricItem.ratings[0].id}']`)
      .simulate('PressOut')
    expect(dismissToolTip).toHaveBeenCalled()
  })
})
