//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
