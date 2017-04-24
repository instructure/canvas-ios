// @flow

import React from 'react'
import SubmissionGrader from '../SubmissionGrader'
import renderer from 'react-test-renderer'

jest.mock('SegmentedControlIOS', () => 'SegmentedControlIOS')
jest.mock('../components/GradePicker')

let defaultProps = {
  submissionID: '1',
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

  it('switches between different tabs', () => {
    let tree = renderer.create(
      <SubmissionGrader {...defaultProps} />
    )

    let instance = tree.getInstance()
    instance.drawer.drawer = { snapTo: jest.fn() }
    let event = {
      nativeEvent: {
        selectedSegmentIndex: 0,
      },
    }
    instance.changeTab(event)
    expect(instance.state.selectedIndex).toEqual(0)

    event.nativeEvent.selectedSegmentIndex = 1
    instance.drawer.drawer = { snapTo: jest.fn() }
    instance.changeTab(event)
    expect(instance.state.selectedIndex).toEqual(1)

    event.nativeEvent.selectedSegmentIndex = 2
    instance.drawer.drawer = { snapTo: jest.fn() }
    instance.changeTab(event)
    expect(instance.state.selectedIndex).toEqual(2)
  })
})
