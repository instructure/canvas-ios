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

/* @flow */

import 'react-native'
import React from 'react'
import PublishedIcon from '../PublishedIcon'
import Images from '../../../images'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders published correctly', () => {
  let tree = renderer.create(
    <PublishedIcon published={true} tintColor='#fff' image={Images.kabob} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders unpublished correctly', () => {
  let tree = renderer.create(
    <PublishedIcon published={false} tintColor='#fff' image={Images.kabob} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
