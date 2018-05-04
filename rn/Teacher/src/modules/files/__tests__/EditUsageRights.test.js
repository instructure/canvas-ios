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
import React from 'react'
import { shallow } from 'enzyme'

import EditUsageRights from '../EditUsageRights'

const selector = {
  copyright: '[identifier="edit-item.usage_rights.legal_copyright"]',
  justification: '[testID="edit-item.usage_rights.use_justification"]',
  justificationPicker: '[testID="edit-item.usage_rights.use_justification.picker"]',
  license: '[testID="edit-item.usage_rights.license"]',
  licensePicker: '[testID="edit-item.usage_rights.license.picker"]',
}

const updatedState = (tree: ShallowWrapper) => new Promise(resolve => tree.setState({}, resolve))

describe('EditUsageRights', () => {
  let props
  beforeEach(() => {
    props = {
      licenses: [
        { id: 'private', name: 'Private (Copyrighted)' },
        { id: 'cc_by', name: 'CC Attribution' },
        { id: 'cc_by_nc_sa', name: 'CC Attribution Non-Commercial Share Alike' },
      ],
      rights: {
        legal_copyright: '',
        use_justification: 'creative_commons',
        license: 'cc_by',
      },
      onChange: jest.fn(),
    }
  })

  it('should render', () => {
    const tree = shallow(<EditUsageRights {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('can change the copyright', () => {
    const tree = shallow(<EditUsageRights {...props} />)
    tree.find(selector.copyright).simulate('ChangeText', 'Me')
    expect(props.onChange).toHaveBeenCalledWith({
      ...props.rights,
      legal_copyright: 'Me',
    })
  })

  it('can change the justification', async () => {
    const tree = shallow(<EditUsageRights {...props} />)
    tree.find(selector.justification).simulate('Press')
    await updatedState(tree)
    tree.find(selector.justificationPicker).simulate('ValueChange', 'own_copyright')
    expect(props.onChange).toHaveBeenCalledWith({
      ...props.rights,
      use_justification: 'own_copyright',
    })
  })

  it('can change the cc license', async () => {
    const tree = shallow(<EditUsageRights {...props} />)
    tree.find(selector.license).simulate('Press')
    await updatedState(tree)
    tree.find(selector.licensePicker).simulate('ValueChange', 'cc_by_nc_sa')
    expect(props.onChange).toHaveBeenCalledWith({
      ...props.rights,
      license: 'cc_by_nc_sa',
    })
  })

  it('does not throw when an invalid license is specified', () => {
    props.rights.license = 'bogus'
    expect(() => shallow(
      <EditUsageRights {...props} />
    )).not.toThrow()
  })

  it('shows blank when no rights are passed in', () => {
    props.rights = undefined
    const tree = shallow(<EditUsageRights {...props} />)
    expect(tree).toMatchSnapshot()
  })
})
