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
import TermsOfUse from '../TermsOfUse'
import { shallow } from 'enzyme'

let templates = {
  ...require('../../../__templates__/helm'),
}

describe('TermsOfUse', () => {
  let defaultProps = {
    navigator: templates.navigator(),
    getTermsOfService: () => Promise.resolve({
      data: {
        content: 'TOS',
        terms_type: 'custom',
        passive: false,
        id: '1',
        account_id: '1',
      },
      headers: {
        link: null,
      },
      status: 200,
    }),
  }

  it('renders a loading screen while things are loading', () => {
    let view = shallow(
      <TermsOfUse
        {...defaultProps}
      />
    )

    let spinner = view.find('ActivityIndicatorView')
    expect(spinner).not.toBeNull()
  })

  it('renders the terms of service once the api call succeeds', async () => {
    let promise = Promise.resolve({
      data: {
        content: 'TOS',
        terms_type: 'custom',
        passive: false,
        id: '1',
        account_id: '1',
      },
      status: 200,
      headers: {
        link: null,
      },
    })

    let view = shallow(
      <TermsOfUse
        {...defaultProps}
        getTermsOfService={() => promise}
      />
    )

    await promise
    view.update()
    let webView = view.find('CanvasWebView')
    expect(webView.props().html).toEqual('TOS')
  })

  it('renders the terms of service once the api call succeeds but has no conent', async () => {
    let promise = Promise.resolve({
      data: {
        content: null,
        terms_type: 'custom',
        passive: false,
        id: '1',
        account_id: '1',
      },
      status: 200,
      headers: {
        link: null,
      },
    })

    let view = shallow(
      <TermsOfUse
        {...defaultProps}
        getTermsOfService={() => promise}
      />
    )

    await promise
    view.update()
    let webView = view.find('CanvasWebView')
    expect(webView.props().html).toEqual('Account has no Terms of Use')
  })

  it('renders the error message when we fail to get the TOS', async () => {
    let promise = Promise.reject()

    let view = shallow(
      <TermsOfUse
        {...defaultProps}
        getTermsOfService={() => promise}
      />
    )

    try {
      await promise
    } catch (e) {
      view.update()
      let text = view.find('Text')
      expect(text).not.toBeNull()
    }
  })
})
