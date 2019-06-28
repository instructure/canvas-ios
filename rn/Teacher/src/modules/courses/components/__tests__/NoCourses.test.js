//
// Copyright (C) 2017-present Instructure, Inc.
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

import { shallow } from 'enzyme'
import React from 'react'
import { NoCourses } from '../NoCourses'

describe('NoCourses', () => {
  it('calls onAddCoursePressed when button is pressed', () => {
    const pressed = jest.fn()
    const tree = shallow(<NoCourses onAddCoursePressed={pressed} />)

    tree.find('[testID="Dashboard.addCoursesButton"]').simulate('Press')
    expect(pressed).toHaveBeenCalled()
  })
})
