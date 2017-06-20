/* @flow */
import 'react-native'
import React from 'react'
import { AddressBook } from '../AddressBook'
// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const template = {
  ...require('../../../api/canvas-api/__templates__/addressBook'),
  ...require('../../../__templates__/helm'),
}

jest.mock('TouchableHighlight', () => 'TouchableHighlight')
jest.mock('react-native-search-bar', () => require('../../../__mocks__/SearchBar').default)

const u1 = template.addressBookResult({
  id: '1',
})
const u2 = template.addressBookResult({
  id: '2',
})

let defaultProps = {
  results: [u1, u2],
  onSelect: jest.fn(),
  onCancel: jest.fn(),
}

beforeEach(() => jest.resetAllMocks())

it('renders correctly', () => {
  const tree = renderer.create(
    <AddressBook {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
