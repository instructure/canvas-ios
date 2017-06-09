// @flow
import { ActionSheetIOS, AlertIOS } from 'react-native'
import React from 'react'
import SubmissionsHeader from '../SubmissionsHeader.js'
import renderer from 'react-test-renderer'

jest.mock('ActionSheetIOS', () => ({
  showActionSheetWithOptions: jest.fn(),
}))
jest.mock('AlertIOS', () => ({
  prompt: jest.fn(),
}))

const filterOptions = [
  {
    type: 'all',
    title: 'all',
  },
  {
    type: 'late',
    title: 'late',
    filterFunc: (submissions: any) => submissions.filter((s) => s.status === 'late'),
  },
  {
    type: 'morethan',
    title: 'morethan',
  },
  {
    type: 'lessthan',
    title: 'lessthan',
  },
  {
    type: 'cancel',
    title: 'cancel',
  }]

test('SubmissionsHeader chose filter function', () => {
  const instance = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} />
  ).getInstance()
  instance.chooseFilter()

  expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalledWith({
    options: [
      'all',
      'late',
      'morethan',
      'lessthan',
      'cancel',
    ],
    cancelButtonIndex: 4,
    title: 'Filter by:',
  }, instance.updateFilter)
})

test('SubmissionsHeader update filter', () => {
  const onSelectFilter = jest.fn()
  const instance = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} onSelectFilter={onSelectFilter} />
  ).getInstance()

  instance.updateFilter(1)

  expect(onSelectFilter).toHaveBeenCalledWith({
    filter: instance.props.filterOptions[1],
  })
})

test('SubmissionsHeader update filter', () => {
  const onSelectFilter = jest.fn()
  const instance = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} onSelectFilter={onSelectFilter} />
  ).getInstance()

  let callback
  const prompt = jest.fn((title, message, cb) => {
    callback = cb
  })
  // $FlowFixMe
  AlertIOS.prompt = prompt
  instance.updateFilter(3)
  expect(prompt).toHaveBeenCalled()
  if (callback) {
    callback()
  }
  expect(onSelectFilter).toHaveBeenCalledWith({
    filter: instance.props.filterOptions[3],
  })
})

test('SubmissionsHeader cancel and clear', () => {
  const onSelectFilter = jest.fn()
  const onClearFilter = jest.fn()
  const instance = renderer.create(
    <SubmissionsHeader filterOptions={filterOptions} onSelectFilter={onSelectFilter} onClearFilter={onClearFilter} />
  ).getInstance()

  instance.updateFilter(4)
  expect(onSelectFilter).not.toHaveBeenCalled()

  instance.clearFilter()
  expect(onClearFilter).toHaveBeenCalled()
})
