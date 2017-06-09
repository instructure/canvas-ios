// @flow

import React from 'react'
import SubmissionGrader from '../SubmissionGrader'
import renderer from 'react-test-renderer'
import DrawerState from '../utils/drawer-state'

jest
  .mock('WebView', () => 'WebView')
  .mock('SegmentedControlIOS', () => 'SegmentedControlIOS')
  .mock('../GradeTab')
  .mock('../components/GradePicker')
  .mock('../components/Header')
  .mock('../components/FilesTab')
  .mock('../comments/CommentsTab')

let template = {
  ...require('../../../api/canvas-api/__templates__/submissions'),
}

let defaultProps = {
  submissionID: '1',
  submissionProps: {},
  drawerState: new DrawerState(),
}

describe('SubmissionGrader', () => {
  beforeEach(() => {
    jest.resetAllMocks()
  })

  it('renders', () => {
    let tree = renderer.create(
      <SubmissionGrader {...defaultProps} />
    )

    let instance = tree.getInstance()
    let event = {
      nativeEvent: {
        layout: {
          height: 200,
          width: 200,
        },
      },
    }
    instance.onLayout(event)
    // expect(tree.toJSON()).toMatchSnapshot()
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

  it('returns a label with the correct number of files', () => {
    let props = {
      selectedIndex: 0,
      submissionProps: {
        submission: template.submissionHistory([{
          attachments: [{}],
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
