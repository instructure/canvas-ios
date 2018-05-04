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

  it('can handle anchors', () => {
    expect(
      shallow(<RichContent html='<a>Drop the anchor</a>' navigator={templates.navigator()} />)
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

  it('can convert an href into an onPress', () => {
    let url = 'https://canvas.instructure.com/courses/4'
    let navigator = templates.navigator()
    let tree = shallow(<RichContent html={`<a href="${url}">A link</a>`} navigator={navigator} />)
    expect(tree).toMatchSnapshot()
    let anchor = tree.find('[onPress]')
    anchor.simulate('press')
    expect(navigator.show).toHaveBeenCalledWith(
      url,
      { deepLink: true, modal: true }
    )
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
