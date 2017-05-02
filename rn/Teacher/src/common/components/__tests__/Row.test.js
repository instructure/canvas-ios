// @flow

import 'react-native'
import React from 'react'
import Row from '../Row'
import Images from '../../../../src/images'

import renderer from 'react-test-renderer'

test('Token renders correctly', () => {
  const onPress = jest.fn()
  let aRow = renderer.create(
    <Row
      title='Title of the row'
      subtitle='Subtitle'
      image={Images.course.assignments}
      imageTint='#fff'
      imageSize={{ height: 10, width: 10 }}
      disclosureIndicator={true}
      height={44}
      border='both'
      onPress={onPress} />
  )
  expect(aRow.toJSON()).toMatchSnapshot()
})
