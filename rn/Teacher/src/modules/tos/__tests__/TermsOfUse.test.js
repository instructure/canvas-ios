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
    let webView = view.find('WebContainer')
    expect(webView.props().html).toEqual('TOS')
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
