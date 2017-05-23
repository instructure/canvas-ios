// @flow

import React from 'react'
import SubmissionGrader from '../SubmissionGrader'
import renderer from 'react-test-renderer'

jest
  .mock('WebView', () => 'WebView')
  .mock('../../../common/components/BottomDrawer', () => 'BottomDrawer')
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
}

describe('SubmissionGrader', () => {
  beforeEach(() => {
    jest.resetAllMocks()
  })

  it('renders', () => {
    let tree = renderer.create(
      <SubmissionGrader {...defaultProps} />
    ).toJSON()

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

  it('returns a label with the correct number of files', () => {
    let props = {
      selectedIndex: 0,
      submissionProps: {
        submission: template.submissionHistory([{
          attachments: [{}],
        }]),
      },
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
})
