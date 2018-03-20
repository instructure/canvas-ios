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
import SubmissionGrader from '../SubmissionGrader'
import renderer from 'react-test-renderer'
import DrawerState from '../utils/drawer-state'
import explore from '../../../../test/helpers/explore'
import { shallow } from 'enzyme'
import * as template from '../../../__templates__'

jest
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('WebView', () => 'WebView')
  .mock('SegmentedControlIOS', () => 'SegmentedControlIOS')
  .mock('../GradeTab')
  .mock('../components/GradePicker')
  .mock('../components/Header')
  .mock('../components/SubmissionPicker', () => 'SubmissionPicker')
  .mock('../components/FilesTab')
  .mock('../components/SimilarityScore')
  .mock('../comments/CommentsTab')
  .mock('../SubmissionViewer', () => 'SubmissionViewer')

let defaultProps = {
  submissionID: '1',
  submissionProps: {},
  drawerState: new DrawerState(),
  closeModal: jest.fn(),
  gradeSubmissionWithRubric: jest.fn(),
}

describe('SubmissionGrader', () => {
  beforeEach(() => {
    jest.resetAllMocks()
  })

  it('renders', () => {
    let tree = shallow(
      <SubmissionGrader {...defaultProps} />
    )

    tree.setState({ width: 200, height: 200 })
    expect(tree).toMatchSnapshot()
  })

  it('renders wide', () => {
    let tree = shallow(
      <SubmissionGrader {...defaultProps} />
    )

    tree.setState({ width: 1000, height: 200 })
    expect(tree).toMatchSnapshot()
  })

  it('can render the handle content', () => {
    let tree = renderer.create(
      <SubmissionGrader {...defaultProps} />
    )
    let handleTree = renderer.create(
      tree.getInstance().renderHandleContent()
    ).toJSON()
    expect(handleTree).toMatchSnapshot()
  })

  it('closes and saves rubric on done press with changes', () => {
    let tree = renderer.create(<SubmissionGrader {...defaultProps} />)
    const gradeTab: any = explore(tree.toJSON()).selectByType('GradeTab')
    gradeTab.props.updateUnsavedChanges({ '1': 'yo' })

    tree.getInstance().donePressed()

    expect(defaultProps.gradeSubmissionWithRubric).toHaveBeenCalled()
    expect(defaultProps.closeModal).toHaveBeenCalled()
  })

  it('closes but does not save rubric on done press without changes ', () => {
    let tree = renderer.create(<SubmissionGrader {...defaultProps} />)

    tree.getInstance().donePressed()

    expect(defaultProps.gradeSubmissionWithRubric).not.toHaveBeenCalled()
    expect(defaultProps.closeModal).toHaveBeenCalled()
  })

  it('saves changes to rubric on swipe (when current student changes)', () => {
    let tree = renderer.create(<SubmissionGrader {...defaultProps} isCurrentStudent={true} />)

    const gradeTab: any = explore(tree.toJSON()).selectByType('GradeTab')
    gradeTab.props.updateUnsavedChanges({ '1': 'yo' })

    tree.getInstance().componentWillReceiveProps({ ...defaultProps, isCurrentStudent: false })

    expect(defaultProps.gradeSubmissionWithRubric).toHaveBeenCalled()
  })

  it('does not saves changes to rubric on swipe (when current student changes but rubric doesnt change)', () => {
    let tree = renderer.create(<SubmissionGrader {...defaultProps} isCurrentStudent={true} />)

    tree.getInstance().componentWillReceiveProps({ ...defaultProps, isCurrentStudent: false })

    expect(defaultProps.gradeSubmissionWithRubric).not.toHaveBeenCalled()
  })

  it('returns a label with the correct number of files', () => {
    let props = {
      selectedIndex: 0,
      selectedAttachmentIndex: 0,
      submissionProps: {
        submission: template.submissionHistory([{
          attachments: [{ preview_url: 'https://google.com' }],
          submission_type: 'online_upload',
        }]),
      },
      drawerState: new DrawerState(),
    }
    let tree = renderer.create(
      <SubmissionGrader {...props} />
    )
    let label = tree.getInstance().filesTabLabel()
    expect(label).toContain('1')
  })

  it('switches between different tabs', () => {
    let tree = renderer.create(
      <SubmissionGrader {...defaultProps} />
    )

    let instance = tree.getInstance()
    let event = {
      nativeEvent: {
        selectedSegmentIndex: 0,
      },
    }
    instance.changeTab(event)
    expect(instance.state.selectedTabIndex).toEqual(0)

    event.nativeEvent.selectedSegmentIndex = 1
    instance.changeTab(event)
    expect(instance.state.selectedTabIndex).toEqual(1)

    event.nativeEvent.selectedSegmentIndex = 2
    instance.changeTab(event)
    expect(instance.state.selectedTabIndex).toEqual(2)
  })

  it('shows number of files on files tab', () => {
    let props = {
      ...defaultProps,
      selectedIndex: null,
      submissionProps: {
        submission: {
          attachments: [
            { fake: 'file' },
            { fake: 'file' },
            { fake: 'file' },
          ],
          submission_type: 'online_upload',
        },
      },
    }

    let tree = renderer.create(
      <SubmissionGrader {...props} />
    )

    let instance = tree.getInstance()
    instance.setState({ height: 200, width: 200, selectedTabIndex: 2 })
    // expect(tree.toJSON()).toMatchSnapshot()
  })

  it('shows no files on files tab', () => {
    let props = {
      ...defaultProps,
      selectedIndex: null,
      submissionProps: {
        submission: {
          fake: 'sub',
        },
      },
    }

    let tree = renderer.create(
      <SubmissionGrader {...props} />
    )

    let instance = tree.getInstance()
    instance.setState({ height: 200, width: 200, selectedTabIndex: 2 })
    tree = tree.toJSON()
    // expect(tree).toMatchSnapshot()
  })

  it('shows number of files on files tab from submission_history', () => {
    let props = {
      ...defaultProps,
      selectedIndex: 1,
      submissionProps: {
        submission: {
          submission_history: [
            { fake: 'sub' },
            {
              attachments: [
                { fake: 'file' },
                { fake: 'file' },
                { fake: 'file' },
              ],
            },
          ],
          submission_type: 'online_upload',
        },
      },
    }

    let tree = renderer.create(
      <SubmissionGrader {...props} />
    )

    let instance = tree.getInstance()
    instance.setState({ height: 200, width: 200, selectedTabIndex: 2 })
    tree = tree.toJSON()
    // expect(tree).toMatchSnapshot()
  })

  it('shows no files on files tab from submission_history', () => {
    let props = {
      ...defaultProps,
      selectedIndex: 0,
      submissionProps: {
        submission: {
          submission_history: [
            {
              fake: 'sub',
            },
          ],
        },
      },
    }

    let tree = renderer.create(
      <SubmissionGrader {...props} />
    )

    let instance = tree.getInstance()
    instance.setState({ height: 200, width: 200, selectedTabIndex: 2 })
    tree = tree.toJSON()
    // expect(tree).toMatchSnapshot()
  })
})
