//
// Copyright (C) 2018-present Instructure, Inc.
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
import { ConferenceList } from '../ConferenceList'
import * as templates from '../../../../__templates__'
import { alertError } from '../../../../redux/middleware/error-handler'

jest.mock('../../../../redux/middleware/error-handler', () => {
  return { alertError: jest.fn() }
})

let props = { }

describe('ConferenceList List', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    props = {
      course: templates.course(),
      navigator: templates.navigator(),
      conferences: [templates.conference()],
      color: '#F00',
      pending: false,
      isLoading: false,
      loadError: null,
      refresh: jest.fn(),
    }
  })

  it('renders', () => {
    props.conferences = null
    const tree = shallow(<ConferenceList { ...props } />)
    expect(tree).toMatchSnapshot()
  })

  it('renders with rows', () => {
    const tree = shallow(<ConferenceList { ...props } />)
    expect(tree).toMatchSnapshot()
  })

  it('shows conference on press', () => {
    props.navigator = templates.navigator({ show: jest.fn() })
    const conference = templates.conference()
    const tree = shallow(<ConferenceList { ...props } />)
    tree.find('FlatList').dive().find('Row').first().simulate('Press', conference)
    expect(props.navigator.show).toHaveBeenCalledWith(conference.join_url)
  })

  it('shows conference on press with no join url', () => {
    props.navigator = templates.navigator({ show: jest.fn() })
    const conference = templates.conference({ join_url: null })
    props.conferences = [conference]
    const tree = shallow(<ConferenceList { ...props } />)
    tree.find('FlatList').dive().find('Row').first().simulate('Press', conference)
    expect(props.navigator.show).toHaveBeenCalledWith('http://mobiledev.instructure.com/courses/1/conferences/1/join')
  })

  it('alerts on new loadError', () => {
    const tree = shallow(<ConferenceList {...props} />)
    tree.setProps({ loadError: null })
    expect(alertError).not.toHaveBeenCalled()
    const loadError = new Error()
    tree.setProps({ loadError })
    expect(alertError).toHaveBeenCalledWith(loadError)
  })
})
