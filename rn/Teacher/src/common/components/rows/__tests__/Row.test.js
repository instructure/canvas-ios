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

import 'react-native'
import React from 'react'
import Row from '../Row'
import Images from '../../../../../src/images'

import renderer from 'react-test-renderer'

test('Render the base row', () => {
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
