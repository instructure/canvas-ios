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
import {
  View,
} from 'react-native'
import renderer from 'react-test-renderer'
import GridView from '../GridView'
import setProps from '../../../../test/helpers/setProps'
import { Text } from '../../../common/text'

let defaultProps = {
  onLayout: () => {},
  data: ['a', 'b'],
  itemsPerRow: 2,
  renderItem: (item) => (
    <Text key={item}>
      {item}
    </Text>
  ),
  placeholderStyle: {},
  style: {},
  onRefresh: jest.fn(),
}

it('renders correctly', () => {
  let tree = renderer.create(<GridView {...defaultProps} />).toJSON()

  expect(tree).toMatchSnapshot()
})

it('renders correctly with sections', () => {
  let tree = renderer.create(
    // I would spread defaultProps here like every where else but for
    // some reason flow complains about that
    <GridView
      onLayout={() => {}}
      placeholderStyle={{}}
      style={{}}
      data={[['a', 'b', 'c'], ['x', 'y']]}
      sections={true}
      renderItem={defaultProps.renderItem}
      onRefresh={jest.fn()}
    />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

it('renders correctly without sections', () => {
  let tree = renderer.create(
    <GridView
      onLayout={() => {}}
      placeholderStyle={{}}
      style={{}}
      data={[['a', 'b', 'c'], ['x', 'y']]}
      sections={false}
      renderItem={defaultProps.renderItem}
      onRefresh={jest.fn()}
    />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

it('renders correctly with placeHolder', () => {
  let tree = renderer.create(
    <GridView
      {...defaultProps}
      data={['a']}
      renderPlaceholder={ (i) => <View/> }
      renderSectionHeader={ (sectionData, sectionText) => <Text>sectionText</Text> }
    />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

it('updates list when data prop changes', () => {
  let tree = renderer.create(
    <GridView {...defaultProps} />
  )

  setProps(tree, { data: ['data changed'] })
  expect(tree.toJSON()).toMatchSnapshot()
})

it('updates list when data prop changes with sections', () => {
  const props = {
    ...defaultProps,
    data: [[]],
    sections: true,
  }
  let tree = renderer.create(
    <GridView {...props} />
  )

  setProps(tree, { data: [['data changed with sections']] })
  expect(tree.toJSON()).toMatchSnapshot()
})

it('calls onRefresh when refresh is called', () => {
  let refresh = jest.fn()
  let tree = renderer.create(
    <GridView {...defaultProps} onRefresh={refresh} />
  )
  let instance = tree.getInstance()
  instance.onRefresh()
  expect(refresh).toHaveBeenCalled()
})
