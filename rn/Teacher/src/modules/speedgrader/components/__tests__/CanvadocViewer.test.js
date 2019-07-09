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

// @flow

import { shallow } from 'enzyme'
import React from 'react'
import * as template from '../../../../__templates__'
import CanvadocViewer from '../CanvadocViewer'

describe('Canvadoc viewer', () => {
  it('renders the native component', () => {
    const config = {
      drawerInset: 0,
      previewPath: template.attachment().preview_url,
      filename: template.attachment().filename,
      fallbackURL: template.attachment().url,
    }
    const tree = shallow(<CanvadocViewer config={config} />)
    expect(tree).toMatchSnapshot()
  })

  it('should not update when props have not changed', () => {
    const config = {
      drawerInset: 0,
      previewPath: template.attachment().preview_url,
      filename: template.attachment().filename,
      fallbackURL: template.attachment().url,
    }
    const tree = shallow(<CanvadocViewer config={config} />)
    expect(tree.instance().shouldComponentUpdate({
      config: { ...config },
    })).toBe(false)
    expect(tree.instance().shouldComponentUpdate({
      config: { ...config, drawerInset: 62 },
    })).toBe(true)
    expect(tree.instance().shouldComponentUpdate({
      config: { ...config, previewPath: 'https://google.com' },
    })).toBe(true)
    expect(tree.instance().shouldComponentUpdate({
      config: { ...config, filename: 'file.jpg' },
    })).toBe(true)
    expect(tree.instance().shouldComponentUpdate({
      config: { ...config, fallbackURL: 'https://google.com' },
    })).toBe(true)
  })
})
