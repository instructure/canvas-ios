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
    jest.resetAllMocks()
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
