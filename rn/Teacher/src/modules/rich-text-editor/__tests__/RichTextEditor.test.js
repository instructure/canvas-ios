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
