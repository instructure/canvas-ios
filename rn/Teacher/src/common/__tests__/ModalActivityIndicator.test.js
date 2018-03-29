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
