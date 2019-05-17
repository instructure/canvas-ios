//
// Copyright (C) 2019-present Instructure, Inc.
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

import showColorOverlayForCourse from '../show-color-overlay-for-course'

import * as template from '../../__templates__'

describe('showColorOverlayForCourse', () => {
  it('show the color overlay when the course has no image', () => {
    let course = template.course({ image_download_url: null })
    expect(showColorOverlayForCourse(course, true)).toEqual(true)
    expect(showColorOverlayForCourse(course, false)).toEqual(true)
  })

  it('show the color overlay when the course has an image and user doesnt want to hide them', () => {
    let course = template.course({ image_download_url: 'https://google.com' })
    expect(showColorOverlayForCourse(course, false)).toEqual(true)
  })

  it('dont show the color overlay when the course has an image and the user wants to hide overlays', () => {
    let course = template.course({ image_download_url: 'https://google.com' })
    expect(showColorOverlayForCourse(course, true)).toEqual(false)
  })
})
