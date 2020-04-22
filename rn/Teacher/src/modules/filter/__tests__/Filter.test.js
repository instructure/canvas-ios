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
import { Alert } from 'react-native'
import Filter from '../Filter'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
import defaultFilterOptions from '../filter-options'

jest
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../routing/Screen')
  .mock('react-native/Libraries/Alert/Alert', () => ({
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

  beforeEach(() => jest.clearAllMocks())

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

    expect(Alert.prompt).toHaveBeenCalled()
    expect(Alert.prompt.mock.calls[0][0]).toEqual('Scored less than…')
    expect(Alert.prompt.mock.calls[0][1]).toEqual(defaultProps.filterPromptMessage)
    expect(Alert.prompt.mock.calls[0][3]).toEqual('plain-text')
    expect(Alert.prompt.mock.calls[0][4]).toEqual('')
    expect(Alert.prompt.mock.calls[0][5]).toEqual('numeric')

    Alert.prompt.mock.calls[0][2]('10')

    let instance = view.getInstance()
    let option = instance.state.filterOptions.find(option => option.type === 'lessthan')
    expect(option.selected).toBeTruthy()
    expect(option.promptValue).toEqual('10')
  })
})
