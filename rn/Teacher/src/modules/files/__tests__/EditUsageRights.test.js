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
import React from 'react'
import { shallow } from 'enzyme'

import EditUsageRights from '../EditUsageRights'

const selector = {
  copyright: '[identifier="FileEditor.copyrightField"]',
  justification: '[testID="FileEditor.justificationButton"]',
  justificationPicker: '[testID="FileEditor.justificationPicker"]',
  license: '[testID="FileEditor.licenseButton"]',
  licensePicker: '[testID="FileEditor.licensePicker"]',
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
