//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import React from 'react'
import { shallow } from 'enzyme'
import RichContent from '../RichContent'
import * as templates from '../../../__templates__/index'

describe('RichContent', () => {
  it('can handle p tags', () => {
    expect(
      shallow(<RichContent html='<p>a wild p tag appears</p>' navigator={templates.navigator()} />)
    ).toMatchSnapshot()
  })

  it('can handle i tags', () => {
    expect(
      shallow(<RichContent html='<i>Deleted reply</i>' navigator={templates.navigator()} />)
    ).toMatchSnapshot()
  })

  it('can handle divs', () => {
    expect(
      shallow(<RichContent html='<div>Some other text</div>' navigator={templates.navigator()} />)
    ).toMatchSnapshot()
  })

  it('can handle fonts', () => {
    expect(
      shallow(<RichContent html='<font>Some font stuff yo</font>' navigator={templates.navigator()} />)
    ).toMatchSnapshot()
  })

  it('can handle spans', () => {
    expect(
      shallow(<RichContent html='<span>Some span-dex</span>' navigator={templates.navigator()} />)
    ).toMatchSnapshot()
  })

  it('can handle bs', () => {
    expect(
      shallow(<RichContent html='<b>You all are getting bees!</b>' navigator={templates.navigator()} />)
    ).toMatchSnapshot()
  })

  it('can handle text at the root', () => {
    expect(
      shallow(<RichContent html='This is some text' navigator={templates.navigator()} />)
    ).toMatchSnapshot()
  })

  it('can convert style rules for RN', () => {
    expect(
      shallow(<RichContent html='<p style="color:#333; min-width:100px; font-variant: small-caps">Some colorful text</p>' navigator={templates.navigator()} />)
    ).toMatchSnapshot()
  })

  it('can convert a color attribute for RN styles', () => {
    expect(
      shallow(<RichContent html='<font color="#333">Some fonty goodness</font>' navigator={templates.navigator()} />)
    ).toMatchSnapshot()
  })

  it('can handle data-api-endpoint and data-api-returntype attributes', () => {
    expect(
      shallow(<RichContent navigator={templates.navigator()} html='<a data-api-endpoint="https://canvas.instructure.com/courses/5" data-api-returntype="application/json">An anchor</a>' />)
    ).toMatchSnapshot()
  })

  it('can handle complex html', () => {
    expect(
      shallow(<RichContent
        navigator={templates.navigator()}
        html={`
          <div>
            <p>
              Some p tag
              <a href='http://google.com'>With an a tag mixed in</a>
              Then some more text that should all be inline
            </p>
            <span>Woah we are spanning it up <b>Boldly</p></span>
            <font color='#eee'>And we will throw some font in there</font>
            <i>How about a little italics</i>
          </div>
          <span>Woah and there is more span <font color='#e3e3e3'>Dope</font></span>
        `}
      />)
    ).toMatchSnapshot()
  })
})
