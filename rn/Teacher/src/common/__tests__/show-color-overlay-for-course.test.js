//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
