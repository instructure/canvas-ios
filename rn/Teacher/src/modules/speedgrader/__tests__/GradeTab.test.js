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

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import { shallow } from 'enzyme'
import { GradeTab, mapStateToProps } from '../GradeTab'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
import { registerScreens } from '../../../routing/register-screens'
import DrawerState from '../utils/drawer-state'
import * as templates from '../../../__templates__'

registerScreens({})
jest.mock('../components/GradePicker')
jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
jest.mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
jest.unmock('react-native/Libraries/Lists/FlatList')

let ownProps = {
  assignmentID: '1',
  courseID: '1',
  submissionID: '1',
  userID: '1',
  navigator: templates.navigator(),
  drawerState: new DrawerState(),
  isModeratedGrading: false,
  updateUnsavedChanges: jest.fn(),
  unsavedChanges: {},
  setScrollEnabled: jest.fn(),
}

let defaultProps = {
  ...ownProps,
  rubricItems: [templates.rubric()],
  rubricSettings: templates.rubricSettings(),
  rubricAssessment: templates.rubricAssessment(),
  gradeSubmissionWithRubric: jest.fn(),
  rubricGradePending: false,
  useRubricForGrading: false,
}

describe('Rubric', () => {
  beforeEach(() => jest.clearAllMocks())

  it('renders the grade picker when there is no rubric', () => {
    let props = {
      ...defaultProps,
      rubricItems: null,
    }
    let tree = renderer.create(
      <GradeTab {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders a rubric', () => {
    let tree = renderer.create(
      <GradeTab {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('calls show with the proper route when a view description is pressed', () => {
    let tree = renderer.create(
      <GradeTab {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('rubric-item.description') || {}
    button.props.onPress()

    expect(defaultProps.navigator.show).toHaveBeenCalledWith(
      `/courses/1/assignments/1/rubrics/${defaultProps.rubricItems[0].id}/description`,
      { modal: true },
    )
  })

  it('has the correct score', () => {
    let component = new GradeTab(defaultProps)
    let tree = shallow(component.renderHeader())
    let score = tree.find('[testID="rubric-score"]')
    expect(score.props().children).toEqual('10 out of 100')

    component = new GradeTab({
      ...defaultProps,
      rubricItems: [templates.rubric({ ignore_for_scoring: true })],
    })
    tree = shallow(component.renderHeader())
    score = tree.find('[testID="rubric-score"]')
    expect(score.props().children).toEqual('0 out of 100')
  })

  it('shows the activity indicator when saving a rubric score', () => {
    let tree = renderer.create(
      <GradeTab {...defaultProps} rubricGradePending={true} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders the comment input when openCommentKeyboard is called', () => {
    let props = {
      ...defaultProps,
      rubricSettings: templates.rubricSettings({ free_form_criterion_comments: true }),
    }
    let tree = renderer.create(
      <GradeTab {...props} />
    )

    tree.getInstance().openCommentKeyboard('2')
    expect(tree.getInstance().state.criterionCommentInput).toEqual('2')
    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('returns null when submitRubricComment is called with an empty message', () => {
    let tree = renderer.create(
      <GradeTab {...defaultProps} />
    )

    tree.getInstance().submitRubricComment({ message: '' })
    expect(defaultProps.gradeSubmissionWithRubric).not.toHaveBeenCalled()
  })

  it('adds the comment to the state correct and updates unsaved changes', () => {
    let tree = renderer.create(
      <GradeTab {...defaultProps} />
    )

    tree.getInstance().openCommentKeyboard('2')
    tree.getInstance().submitRubricComment({ comment: 'A Message' })
    expect(tree.getInstance().state.ratings['2'].comments).toEqual('A Message')
    expect(defaultProps.updateUnsavedChanges).toHaveBeenCalledWith(
      {
        2: { comments: 'A Message', points: 10, rating_id: '3' },
      },
    )
  })

  it('remove the comment from the state correctly and updates unsaved changes', () => {
    let tree = renderer.create(
      <GradeTab {...defaultProps} />
    )

    tree.getInstance().setState({ ratings: { '2': { points: 10, comments: 'a' } } })
    tree.getInstance().deleteComment('2')

    expect(tree.getInstance().state.ratings['2'].comments).toEqual('')
    expect(defaultProps.updateUnsavedChanges).toHaveBeenCalledWith(
      {
        2: { comments: '', points: 10 },
      },
    )
  })

  it('updateUnsavedChanges called when rubric changes', () => {
    let tree = renderer.create(
      <GradeTab {...defaultProps} />
    )
    let button = explore(tree.toJSON()).selectByID(`rubric-item.points-${defaultProps.rubricItems[0].ratings[0].id}`) || {}
    button.props.onPress()

    expect(defaultProps.updateUnsavedChanges).toHaveBeenCalledWith(tree.getInstance().state.ratings)
  })

  it('can toggle scrolling', () => {
    let tree = renderer.create(
      <GradeTab {...defaultProps} />
    )
    let instance = tree.getInstance()
    instance.scrollView.setNativeProps = jest.fn()

    instance.setScrollEnabled(false)
    expect(instance.scrollView.setNativeProps).toHaveBeenCalledWith({ scrollEnabled: false })
    expect(defaultProps.setScrollEnabled).toHaveBeenCalledWith(false)

    instance.setScrollEnabled(true)
    expect(instance.scrollView.setNativeProps).toHaveBeenCalledWith({ scrollEnabled: true })
    expect(defaultProps.setScrollEnabled).toHaveBeenCalledWith(true)
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

  it('returns the grading pending value', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '1': {
            data: {},
          },
        },
        submissions: {
          '1': {
            rubricGradePending: true,
            submission: {
              rubric_assessment: {},
            },
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props.rubricGradePending).toEqual(true)
  })
})
