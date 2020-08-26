//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import { shallow } from 'enzyme'
import React from 'react'
import * as template from '../../../../__templates__'
import DocViewer from '../DocViewer'

describe('DocViewer', () => {
  const props = {
    contentInset: { bottom: 0 },
    fallbackURL: template.attachment().url,
    filename: template.attachment().filename,
    previewURL: template.attachment().preview_url,
  }

  it('renders the native component', () => {
    const tree = shallow(<DocViewer {...props} />)
    expect(tree.find('DocViewer').exists()).toBe(true)
  })

  it('should not update when props have not changed', () => {
    const view = shallow(<DocViewer {...props} />).instance()
    expect(view.shouldComponentUpdate(props)).toBe(false)
    expect(view.shouldComponentUpdate({ ...props, contentInset: { bottom: 62 } })).toBe(true)
    expect(view.shouldComponentUpdate({ ...props, fallbackURL: 'https://google.com' })).toBe(true)
    expect(view.shouldComponentUpdate({ ...props, filename: 'file.jpg' })).toBe(true)
    expect(view.shouldComponentUpdate({ ...props, previewURL: 'https://google.com' })).toBe(true)
  })
})
