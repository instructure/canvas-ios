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

// @flow

import React from 'react'
import { shallow } from 'enzyme'
import Slider from '../Slider'

jest.useFakeTimers()

function setWidthOfTree (tree) {
  tree.instance().onLayout({
    nativeEvent: {
      layout: {
        width: 130,
      },
    },
  })
}

describe('Slider', () => {
  let props = {
    excused: false,
    score: 10,
    pointsPossible: 100,
    setScrollEnabled: jest.fn(),
    setScore: jest.fn(),
    excuseAssignment: jest.fn(),
  }

  beforeEach(() => jest.clearAllMocks())
  afterEach(() => jest.clearAllTimers())

  it('renders', () => {
    let tree = shallow(<Slider {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('can render the tooltip score', () => {
    let tree = shallow(<Slider {...props} />)
    setWidthOfTree(tree)
    tree.setState({ showTooltip: true })
    tree.update()
    let tooltipText = tree.find('[testID="slider.tooltip-text"]')
    expect(tooltipText.props().children).toEqual(props.score.toString())
  })

  it('can render the tooltip with No grade', () => {
    let tree = shallow(<Slider {...props} />)
    setWidthOfTree(tree)
    tree.instance().moveTo(0)
    jest.runAllTimers()
    tree.setState({ showTooltip: true })
    let tooltipText = tree.find('[testID="slider.tooltip-text"]')
    expect(tooltipText.props().children).toEqual('No Grade')
  })

  it('can render the tooltip with Excused', () => {
    let tree = shallow(<Slider {...props} />)
    setWidthOfTree(tree)
    tree.instance().moveTo(100)
    jest.runAllTimers()
    tree.setState({ showTooltip: true })
    let tooltipText = tree.find('[testID="slider.tooltip-text"]')
    expect(tooltipText.props().children).toEqual('Excused')
  })

  it('rounds the score', () => {
    let tree = shallow(<Slider {...props} />)
    let instance = tree.instance()
    setWidthOfTree(tree)

    instance.moveTo(50.1)
    tree.setState({ showTooltip: true })
    expect(tree.find('[testID="slider.tooltip-text"]').props().children).toEqual('50')

    instance.moveTo(50.5)
    tree.setState({ showTooltip: true })
    expect(tree.find('[testID="slider.tooltip-text"]').props().children).toEqual('51')
  })

  it('uses the max score if the slider is slid all the way over', () => {
    let tree = shallow(<Slider {...props} pointsPossible={100.4} />)
    let instance = tree.instance()
    setWidthOfTree(tree)

    instance.moveTo(100)
    tree.setState({ showTooltip: true })
    expect(tree.find('[testID="slider.tooltip-text"]').props().children).toEqual('100.4')
  })

  it('saves the score when finished', () => {
    let tree = shallow(<Slider {...props} />)
    let instance = tree.instance()
    setWidthOfTree(tree)
    tree.setState({ showTooltip: true })
    instance.moveTo(50)

    expect(instance.slide._value).toEqual(0)
    expect(instance.slide._offset).toEqual(50)
    expect(props.setScrollEnabled).toHaveBeenCalledWith(true)
    expect(tree.state('showTooltip')).toEqual(false)
    jest.runAllTimers()
    expect(props.setScore).toHaveBeenCalledWith('50')
  })

  it('sets the score to zero when zero is pressed', () => {
    let tree = shallow(<Slider {...props} />)
    let instance = tree.instance()
    setWidthOfTree(tree)
    let button = tree.find('[testID="slider.zero"]')
    button.simulate('press')

    expect(instance.value).toEqual(0)
    jest.runAllTimers()
    expect(props.setScore).toHaveBeenCalledWith('0')
  })

  it('sets the score to points possible when the points possible is pressed', () => {
    let tree = shallow(<Slider {...props} />)
    let instance = tree.instance()
    setWidthOfTree(tree)
    let button = tree.find('[testID="slider.pointsPossible"]')
    button.simulate('press')
    tree.update()

    expect(instance.value).toEqual(100)
    jest.runAllTimers()
    expect(props.setScore).toHaveBeenCalledWith('100')
  })

  it('slides when you tap somewhere on the line', () => {
    let tree = shallow(<Slider {...props} />)
    let instance = tree.instance()
    setWidthOfTree(tree)
    let line = tree.find('[testID="slider.line"]')
    line.simulate('responderRelease', {
      nativeEvent: {
        locationX: 50,
      },
    })
    tree.update()

    expect(instance.value).toEqual(35)
    jest.runAllTimers()
    expect(props.setScore).toHaveBeenCalledWith('35')
  })

  it('sets excused when the slider is held at the right side', () => {
    let tree = shallow(<Slider {...props} />)
    setWidthOfTree(tree)
    // $FlowFixMe
    Object.values(tree.instance().slide._listeners)[0]({ value: 100 })
    jest.runAllTimers()
    expect(tree.state('excused')).toEqual(true)

    tree.instance().interactionFinished()
    jest.runAllTimers()
    expect(props.excuseAssignment).toHaveBeenCalled()
  })

  it('sets noGrade when the slider is held at the left side', () => {
    let tree = shallow(<Slider {...props} />)
    setWidthOfTree(tree)
    // $FlowFixMe
    Object.values(tree.instance().slide._listeners)[0]({ value: 0 })
    jest.runAllTimers()
    expect(tree.state('noGrade')).toEqual(true)

    tree.instance().interactionFinished()
    jest.runAllTimers()
    expect(props.setScore).toHaveBeenCalledWith('')
  })

  it('will excuse the assignment when excused is true', () => {
    let tree = shallow(<Slider {...props} />)
    let instance = tree.instance()
    setWidthOfTree(tree)
    tree.setState({ excused: true })
    instance.interactionFinished()
    jest.runAllTimers()
    expect(props.excuseAssignment).toHaveBeenCalled()
  })

  it('will grade with no grade when noGrade is true', () => {
    let tree = shallow(<Slider {...props} />)
    let instance = tree.instance()
    setWidthOfTree(tree)
    tree.setState({ noGrade: true })
    instance.interactionFinished()
    jest.runAllTimers()
    expect(props.setScore).toHaveBeenCalledWith('')
  })

  it('can increment for accessibility', () => {
    let tree = shallow(<Slider {...props} />)
    setWidthOfTree(tree)

    tree.setState({ showTooltip: true })
    expect(tree.find('[testID="slider.tooltip-text"]').props().children).toEqual('10')

    let slider = tree.find('[testID="slider.adjustable"]')
    slider.simulate('accessibilityIncrement')
    jest.runAllTimers()
    tree.setState({ showTooltip: true })
    expect(tree.find('[testID="slider.tooltip-text"]').props().children).toEqual('11')
    expect(props.setScore).toHaveBeenCalledWith('11')
  })

  it('can decrement for accessibility', () => {
    let tree = shallow(<Slider {...props} />)
    setWidthOfTree(tree)

    tree.setState({ showTooltip: true })
    expect(tree.find('[testID="slider.tooltip-text"]').props().children).toEqual('10')

    let slider = tree.find('[testID="slider.adjustable"]')
    slider.simulate('accessibilityDecrement')
    jest.runAllTimers()
    tree.setState({ showTooltip: true })
    expect(tree.find('[testID="slider.tooltip-text"]').props().children).toEqual('9')
    expect(props.setScore).toHaveBeenCalledWith('9')
  })
})
