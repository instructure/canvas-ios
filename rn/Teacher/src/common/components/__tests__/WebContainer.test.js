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
import { shallow } from 'enzyme'
import React from 'react'
import WebContainer from '../WebContainer'
import RCTSFSafariViewController from 'react-native-sfsafariviewcontroller'
import { setSession } from '../../../canvas-api'

jest
  .unmock('ScrollView')
  .mock('WebView', () => 'WebView')
  .mock('../../../routing/Screen')
  .mock('react-native-sfsafariviewcontroller', () => {
    return {
      open: jest.fn(),
    }
  })
  .mock('../../../canvas-api')

const template = {
  ...require('../../../__templates__/session'),
  ...require('../../../__templates__/helm'),
}

describe('WebContainer', () => {
  beforeAll(() => {
    setSession(template.session())
  })

  it('renders', () => {
    let tree = shallow(<WebContainer />)
    expect(tree).toMatchSnapshot()
  })

  it('renders html', () => {
    let html = '<div>hello world</div>'
    let tree = shallow(<WebContainer html={html} />)
    tree.simulate('Layout', { nativeEvent: { layout: { width: 300 } } })
    expect(tree).toMatchSnapshot()
  })

  it('adds mathjax if needed', () => {
    let html = '<math><mrow><msup><mi>&nbsp; a </mi><mn>2</mn></msup> <mo> + </mo> <msup><mi> b </mi><mn>2</mn></msup> <mo> = </mo> <msup><mi> c </mi><mn>2</mn></msup> </mrow> </math>'
    let tree = shallow(<WebContainer html={html} />)
    tree.simulate('Layout', { nativeEvent: { layout: { width: 300 } } })
    expect(tree).toMatchSnapshot()
  })

  it('renders with width zero', () => {
    let html = '<div>hello world</div>'
    let tree = shallow(<WebContainer html={html} />)
    tree.simulate('Layout', { nativeEvent: { layout: { width: 0 } } })
    expect(tree).toMatchSnapshot()
  })

  it('updates height from js', () => {
    let html = '<div>hello world</div>'
    let tree = shallow(<WebContainer html={html} />)
    tree.simulate('Layout', { nativeEvent: { layout: { width: 300 } } })

    const data = JSON.stringify({ type: 'UPDATE_HEIGHT', data: 10 })
    const message = {
      nativeEvent: { data },
    }

    tree.find('WebView').simulate('Message', message)
    expect(tree).toMatchSnapshot()
  })

  it('updates height from js with scroll disabled', () => {
    let html = '<div>hello world</div>'
    let tree = shallow(<WebContainer html={html} scrollEnabled={false} />)
    tree.simulate('Layout', { nativeEvent: { layout: { width: 300 } } })

    const data = JSON.stringify({ type: 'UPDATE_HEIGHT', data: 10 })
    const message = {
      nativeEvent: { data },
    }

    tree.find('WebView').simulate('Message', message)
    expect(tree).toMatchSnapshot()
  })

  // External links
  it('handles external links', () => {
    let html = '<div>hello world</div>'
    let tree = shallow(<WebContainer html={html} />)
    tree.simulate('Layout', { nativeEvent: { layout: { width: 300 } } })
    tree.find('WebView').simulate('ShouldStartLoadWithRequest')
    expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()
    tree.find('WebView').simulate('ShouldStartLoadWithRequest', {
      url: 'http://www.google.com',
      navigationType: 'click',
    })
    expect(RCTSFSafariViewController.open).toHaveBeenCalledWith('http://www.google.com')
  })

  it('handles external link that does not exist', () => {
    jest.resetAllMocks()
    let html = '<div>hello world</div>'
    let tree = shallow(<WebContainer html={html} />)
    tree.simulate('Layout', { nativeEvent: { layout: { width: 300 } } })
    tree.find('WebView').simulate('ShouldStartLoadWithRequest')
    expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()
    tree.find('WebView').simulate('ShouldStartLoadWithRequest')
    expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()
  })

  it('handles external link, then reload of the content', () => {
    jest.resetAllMocks()
    let html = '<div>hello world</div>'
    let tree = shallow(<WebContainer html={html} />)
    tree.simulate('Layout', { nativeEvent: { layout: { width: 300 } } })
    tree.find('WebView').simulate('ShouldStartLoadWithRequest')
    expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()
    tree.find('WebView').simulate('ShouldStartLoadWithRequest', {
      url: 'http://www.google.com',
      navigationType: 'click',
    })
    expect(RCTSFSafariViewController.open).toHaveBeenCalledWith('http://www.google.com')
    jest.resetAllMocks()
    tree.find('WebView').simulate('ShouldStartLoadWithRequest', {
      url: 'about:blank',
      navigationType: 'other',
    })
    expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()
  })

  it('handles internal link loads authenticated url', async () => {
    jest.resetAllMocks()
    let html = '<div>hello world</div>'
    const navigator = template.navigator({
      show: jest.fn(),
    })
    let tree = shallow(
      <WebContainer html={html} navigator={navigator} />
    )
    tree.simulate('Layout', { nativeEvent: { layout: { width: 300 } } })
    tree.find('WebView').simulate('ShouldStartLoadWithRequest')
    expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()

    tree.find('WebView').simulate('ShouldStartLoadWithRequest', {
      url: 'http://mobiledev.instructure.com/courses/1/discussion_topics/1',
      navigationType: 'click',
    })
    expect(navigator.show).toHaveBeenCalledWith(
      'http://mobiledev.instructure.com/courses/1/discussion_topics/1',
      {
        deepLink: true,
      },
    )
  })
})
