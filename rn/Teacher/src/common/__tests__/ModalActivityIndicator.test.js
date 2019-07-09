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

/**
 * @flow
 */

import 'react-native'
import React from 'react'
import ModalOverlay from '../components/ModalOverlay'
import { shallow } from 'enzyme'

const props = {
  text: 'hello world',
}

describe('ModalActivitiyIndicator', () => {
  it('renders modal activity indicator', () => {
    let tree = shallow(<ModalOverlay {...props} />)
    expect(tree.find('ModalOverlayText').props().children).toEqual(props.text)
    expect(tree.find('ActivityIndicator').length).toEqual(1)
  })

  it('doesnt render the activity indicator when told not to', () => {
    let tree = shallow(<ModalOverlay {...props} showActivityIndicator={false} />)
    expect(tree.find('AcitivityIndicator').length).toEqual(0)
  })
})
