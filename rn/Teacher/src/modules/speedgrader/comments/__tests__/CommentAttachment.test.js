//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import 'react-native'
import React from 'react'
import { shallow } from 'enzyme'
import CommentAttachment from '../CommentAttachment'
import * as template from '../../../../__templates__/'
import icon from '../../../../images/inst-icons'

describe('CommentAttachment', () => {
  let props
  beforeEach(() => {
    props = {
      from: 'them',
      attachment: template.attachment(),
    }
  })

  it('renders attachment', () => {
    props.attachment.display_name = 'screenshot.png'
    let view = shallow(<CommentAttachment {...props} />)
    expect(view.find('Image').prop('source')).toEqual(icon('paperclip'))
    expect(view.find('Text').children().text()).toEqual('screenshot.png')
  })

  it('renders theirs styles', () => {
    props.from = 'them'
    let view = shallow(<CommentAttachment {...props} />)
    expect(view.prop('style')[1].justifyContent).toEqual('flex-start')
  })

  it('renders mine styles', () => {
    props.from = 'me'
    let view = shallow(<CommentAttachment {...props} />)
    expect(view.prop('style')[1].justifyContent).toEqual('flex-end')
  })
})
