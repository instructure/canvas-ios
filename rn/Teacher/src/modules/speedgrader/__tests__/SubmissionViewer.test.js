// @flow

import React from 'react'
import SubmissionViewer from '../SubmissionViewer'
import renderer from 'react-test-renderer'

jest
  .mock('WebView', () => 'Webview')

let defaultSelections = {
  selectedIndex: null,
  selectedAttachmentIndex: null,
}

let defaultSub = {
  name: 'Allura',
  avatarURL: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
  status: 'none',
  userID: '4',
  grade: 'not_submitted',
  submissionID: null,
  submission: null,
}

describe('SubmissionViewer', () => {
  it('renders an online_text_entry submission', () => {
    let sub = {
      ...defaultSub,
      submission: {
        submission_type: 'online_text_entry',
        body: '<p>Form Voltron</p>',
      },
    }

    let props = {
      ...defaultSelections,
      submissionProps: sub,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders no submission', () => {
    let props = {
      ...defaultSelections,
      submissionProps: defaultSub,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
