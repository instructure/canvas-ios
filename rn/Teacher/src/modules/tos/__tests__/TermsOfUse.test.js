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
