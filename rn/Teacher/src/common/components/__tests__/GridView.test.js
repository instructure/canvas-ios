// @flow

import React from 'react'
import {
  Text,
  View,
} from 'react-native'
import renderer from 'react-test-renderer'
import GridView from '../GridView'
import setProps from '../../../../test/helpers/setProps'

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
