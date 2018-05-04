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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import React from 'react'
import { Refreshed } from '../AllCourseList'

const template = {
  ...require('../../../../__templates__/course'),
}

describe('AllCourseList', () => {
  it('refreshes courses when empty', () => {
    const refreshCourses = jest.fn()
    const refreshProps = {
      courses: [],
      refreshCourses,
    }

    const tree = shallow(<Refreshed {...refreshProps} />)
    expect(tree).toMatchSnapshot()
    expect(refreshCourses).toHaveBeenCalled()
  })

  it('no refresh when at least one course exists', () => {
    const refreshCourses = jest.fn()
    const refreshProps = {
      courses: [],
      refreshCourses,
    }
    const course = template.course()

    const tree = shallow(<Refreshed {...refreshProps} />)
    expect(tree).toMatchSnapshot()
    expect(refreshCourses).toHaveBeenCalledTimes(1)
    expect(tree.refreshing).toBeFalsy()
    refreshProps.courses[0] = course
    tree.setProps(refreshProps)
    expect(refreshCourses).toHaveBeenCalledTimes(1)
  })

  it('refreshes with new props', () => {
    const refreshCourses = jest.fn()
    const refreshProps = {
      courses: [],
      refreshCourses,
    }

    let tree = shallow(<Refreshed {...refreshProps} />)
    expect(tree).toMatchSnapshot()
    tree.instance().refresh()
    tree.setProps(refreshProps)
    expect(refreshCourses).toHaveBeenCalledTimes(2)
  })
})
