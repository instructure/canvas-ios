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
import 'react-native'
import { shallow } from 'enzyme'
import RichTextEditor from '../RichTextEditor'
import * as template from '../../../__templates__/'

describe('RichTextEditor', () => {
  let props
  beforeEach(() => {
    props = {
      navigator: template.navigator(),
    }
  })

  it('renders', () => {
    expect(shallow(<RichTextEditor {...props} />)).toMatchSnapshot()
  })

  it('passes back html on done pressed', async () => {
    props.onChangeValue = jest.fn()
    const view = shallow(<RichTextEditor {...props} />)
    const html = '<div>HTML ON DONE</div>'
    view.find('RichTextEditor').getElement().ref({ getHTML: jest.fn(() => Promise.resolve(html)) })
    await view.prop('leftBarButtons')[0].action()
    expect(props.onChangeValue).toHaveBeenCalledWith(html)
  })

  it('dismisses on done pressed', async () => {
    props.navigator = template.navigator({ dismiss: jest.fn() })
    const view = shallow(<RichTextEditor {...props} />)
    view.find('RichTextEditor').getElement().ref({ getHTML: jest.fn(() => Promise.resolve('')) })
    await view.prop('leftBarButtons')[0].action()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })
})
