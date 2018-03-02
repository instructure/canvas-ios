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
import SubmissionStatusLabel from '../SubmissionStatusLabel'
import renderer from 'react-test-renderer'

describe('SubmissionStatus', () => {
  it('status `none` renders properly', () => {
    let tree = renderer.create(
      <SubmissionStatusLabel status={'none'} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('status `missing` renders properly', () => {
    let tree = renderer.create(
      <SubmissionStatusLabel status={'missing'} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('status `late` renders properly', () => {
    let tree = renderer.create(
      <SubmissionStatusLabel status={'late'} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('status `submitted` renders properly', () => {
    let tree = renderer.create(
      <SubmissionStatusLabel status={'submitted'} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('status `excused` renders properly', () => {
    let tree = renderer.create(
      <SubmissionStatusLabel status='excused' />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })
})
