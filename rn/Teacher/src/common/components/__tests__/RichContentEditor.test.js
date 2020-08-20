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

import { shallow } from 'enzyme'
import React from 'react'
import RichContentEditor from '../RichContentEditor'

describe('RichContentEditor', () => {
  const props = {
    context: 'courses/1',
    html: 'default html',
    onFocus: jest.fn(),
    placeholder: 'placehold',
    uploadContext: 'users/self/files',
  }

  it('renders native component', () => {
    const tree = shallow(<RichContentEditor {...props} />)
    expect(tree.find('RichContentEditor').exists()).toBe(true)
  })

  it('can retrieve html', async () => {
    const tree = shallow(<RichContentEditor {...props} />)
    expect(await tree.instance().getHTML()).toBe('html')
  })
})
