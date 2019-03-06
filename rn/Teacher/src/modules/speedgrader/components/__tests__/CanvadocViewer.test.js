//
// Copyright (C) 2017-present Instructure, Inc.
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
