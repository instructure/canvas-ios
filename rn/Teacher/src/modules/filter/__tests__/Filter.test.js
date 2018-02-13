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
import { AlertIOS } from 'react-native'
import Filter from '../Filter'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
import defaultFilterOptions from '../filter-options'

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../routing/Screen')
  .mock('AlertIOS', () => ({
    prompt: jest.fn(),
  }))

let template = {
  ...require('../../../__templates__/helm'),
}

describe('Filter', () => {
  let defaultProps = {
    navigator: template.navigator(),
    filterOptions: defaultFilterOptions(),
    applyFilter: jest.fn(),
    filterPromptMessage: 'This be a test',
  }

  beforeEach(() => jest.resetAllMocks())

  it('renders the filter options', () => {
    let tree = renderer.create(
      <Filter {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders with preselected options', () => {
    let tree = renderer.create(
      <Filter {...defaultProps} filterOptions={defaultFilterOptions('graded')} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('resets all filter options when reset is pressed', () => {
    let view = renderer.create(
      <Filter {...defaultProps} filterOptions={defaultFilterOptions('graded')} />
    )

    let instance = view.getInstance()
    expect(instance.state.filterOptions.some(option => option.selected)).toBeTruthy()

    let resetButton = explore(view.toJSON()).selectLeftBarButton('filter.reset')
    resetButton.action()

    expect(instance.state.filterOptions.every(option => !option.selected && !option.promptValue)).toBeTruthy()
  })

  it('calls applyFilter with the new filter options and then dismisses itself when done is pressed', () => {
    let view = renderer.create(
      <Filter {...defaultProps} />
    )

    let doneButton = explore(view.toJSON()).selectRightBarButton('filter.done')
    doneButton.action()

    expect(defaultProps.applyFilter).toHaveBeenCalledWith(view.getInstance().state.filterOptions)
    expect(defaultProps.navigator.dismiss).toHaveBeenCalled()
  })

  it('updates the selection when pressed for non prompt filter options', () => {
    let view = renderer.create(
      <Filter {...defaultProps} />
    )

    let row = explore(view.toJSON()).selectByID('filter.option-graded')
    row.props.onPress()

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('prompts for a value when a prompt filter option is pressed', () => {
    let view = renderer.create(
      <Filter {...defaultProps} />
    )

    let row = explore(view.toJSON()).selectByID('filter.option-lessthan')
    row.props.onPress()

    expect(AlertIOS.prompt).toHaveBeenCalled()
    expect(AlertIOS.prompt.mock.calls[0][0]).toEqual('Scored less than…')
    expect(AlertIOS.prompt.mock.calls[0][1]).toEqual(defaultProps.filterPromptMessage)
    expect(AlertIOS.prompt.mock.calls[0][3]).toEqual('plain-text')
    expect(AlertIOS.prompt.mock.calls[0][4]).toEqual('')
    expect(AlertIOS.prompt.mock.calls[0][5]).toEqual('numeric')

    AlertIOS.prompt.mock.calls[0][2]('10')

    let instance = view.getInstance()
    let option = instance.state.filterOptions.find(option => option.type === 'lessthan')
    expect(option.selected).toBeTruthy()
    expect(option.promptValue).toEqual('10')
  })
})
