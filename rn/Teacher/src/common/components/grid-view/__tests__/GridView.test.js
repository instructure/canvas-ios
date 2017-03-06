// @flow

import React from 'react'
import {
  Text,
  View,
} from 'react-native'

import renderer from 'react-test-renderer'

import GridView from '../GridView'

it('renders correctly', () => {
  let tree = renderer.create(<GridView data={['a', 'b', 'c']} itemsPerRow={2} renderItem={(item) => (
    <Text key={item}>
      {item}
    </Text>
  )}/>).toJSON()

  expect(tree).toMatchSnapshot()
})

it('renders correctly with placeHolder', () => {
  let tree = renderer.create(<GridView data={['a', 'b']} itemsPerRow={2} renderItem={(item) => (
    <Text key={item}>
      {item}
    </Text>
  )}/>).toJSON()

  expect(tree).toMatchSnapshot()
})

it('renders correctly with sections', () => {
  let tree = renderer.create(<GridView data={[['a', 'b', 'c'], ['x', 'y']]} itemsPerRow={2} sections={true} renderItem={(item) => (
    <Text key={item}>
      {item}
    </Text>
  )}/>).toJSON()

  expect(tree).toMatchSnapshot()
})

it('renders correctly with placeHolder', () => {
  let tree = renderer.create(<GridView data={['a']} itemsPerRow={2} renderItem={(item) => (
    <Text key={item}>
      {item}
    </Text>
  )} renderPlaceholder={ (i) => { (<View/>) }

  } renderSectionHeader={ (sectionData, sectionText) => (<Text>sectionText</Text>) }/>).toJSON()

  expect(tree).toMatchSnapshot()
})
