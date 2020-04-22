//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

// @flow

import React from 'react'
import { shallow } from 'enzyme'
import { SectionSelector, mapStateToProps } from '../SectionSelector'

const templates = {
  ...require('../../../../__templates__/section'),
  ...require('../../../../__templates__/course'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../redux/__templates__/app-state'),
}

function resetProps () {
  return {
    courseID: '1',
    updateSelectedSections: jest.fn(),
    refreshSections: jest.fn(),
    sections: [templates.section({ course_id: '1' })],
    courseName: 'Course',
    navigator: templates.navigator(),
    currentSelectedSections: [],
  }
}

describe('SectionSelector', () => {
  let props = resetProps()
  beforeEach(() => {
    props = resetProps()
    jest.clearAllMocks()
  })

  it('renders a screen', () => {
    let view = shallow(<SectionSelector {...props} />)
    expect(view.find('Screen')).not.toBeNull()
  })

  it('uses the course name as the title', () => {
    let view = shallow(<SectionSelector {...props} />)
    expect(view.find('Screen').props().title.includes(props.courseName)).toBeTruthy()
  })

  it('refreshes sections on mount', () => {
    shallow(<SectionSelector {...props} />)
    expect(props.refreshSections).toHaveBeenCalledWith(props.courseID)
  })

  it('allows for toggling a section', () => {
    let view = shallow(<SectionSelector {...props} />)
    let row = shallow(view.instance().renderSection({ item: props.sections[0] }))
    expect(row.find('Image').length).toEqual(0)

    row.simulate('press')
    row = shallow(view.instance().renderSection({ item: props.sections[0] }))
    expect(row.find('Image').length).toEqual(1)
    expect(props.updateSelectedSections).toHaveBeenLastCalledWith(view.state().selectedSections)

    row.simulate('press')
    row = shallow(view.instance().renderSection({ item: props.sections[0] }))
    expect(row.find('Image').length).toEqual(0)
    expect(props.updateSelectedSections).toHaveBeenLastCalledWith(view.state().selectedSections)
  })

  it('can have a default selection', () => {
    let view = shallow(<SectionSelector {...props} currentSelectedSections={[props.sections[0].id]} />)
    let row = shallow(view.instance().renderSection({ item: props.sections[0] }))
    expect(row.find('Image').length).toEqual(1)
  })
})

describe('mapStateToProps', () => {
  let appState = templates.appState({
    entities: {
      courses: {
        '1': {
          course: templates.course({ id: '1' }),
        },
      },
      sections: {
        '1': templates.section({ id: '1', course_id: '1' }),
      },
    },
  })

  const ownProps = {
    courseID: '1',
    currentSelectedSections: [],
    updateSelectedSections: jest.fn(),
  }

  it('returns an array of sections for the course', () => {
    let props = mapStateToProps(appState, ownProps)
    expect(props.sections).toMatchObject([{ id: '1' }])
  })

  it('returns the courseName', () => {
    let props = mapStateToProps(appState, ownProps)
    expect(props.courseName).toEqual(appState.entities.courses['1'].course.name)
  })
})
