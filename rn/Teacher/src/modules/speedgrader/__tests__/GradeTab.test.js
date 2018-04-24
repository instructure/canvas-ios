//
// Copyright (C) 2016-present Instructure, Inc.
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

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import { GradeTab, mapStateToProps } from '../GradeTab'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
import { registerScreens } from '../../../routing/register-screens'
import DrawerState from '../utils/drawer-state'

registerScreens({})
jest.mock('../components/GradePicker')
jest.mock('TouchableOpacity', () => 'TouchableOpacity')
jest.mock('TouchableHighlight', () => 'TouchableHighlight')

const templates = {
  ...require('../../../__templates__/rubric'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
}

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
  beforeEach(() => jest.resetAllMocks())

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
    let tree = renderer.create(
      <GradeTab {...defaultProps} />
    )

    tree.getInstance().setState({ ratings: { '2': 10 } })

    expect(tree.toJSON()).toMatchSnapshot()
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

    tree.getInstance().openCommentKeyboard('1')
    expect(tree.getInstance().state.criterionCommentInput).toEqual('1')
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

    tree.getInstance().openCommentKeyboard('1')
    tree.getInstance().submitRubricComment({ message: 'A Message' })
    expect(tree.getInstance().state.ratings['1'].comments).toEqual('A Message')
    expect(defaultProps.updateUnsavedChanges).toHaveBeenCalledWith(
      {
        1: { comments: 'A Message', points: 10 },
      },
    )
  })

  it('remove the comment from the state correctly and updates unsaved changes', () => {
    let tree = renderer.create(
      <GradeTab {...defaultProps} />
    )

    tree.getInstance().setState({ ratings: { '1': { points: 10, comments: 'a' } } })
    tree.getInstance().deleteComment('1')

    expect(tree.getInstance().state.ratings['1'].comments).toEqual('')
    expect(defaultProps.updateUnsavedChanges).toHaveBeenCalledWith(
      {
        1: { comments: '', points: 10 },
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
