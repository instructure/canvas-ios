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
      assignmentSubmissionTypes: ['online_text_entry'],
      submissionProps: sub,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders an online_quiz submission', () => {
    let sub = {
      ...defaultSub,
      submission: {
        submission_type: 'online_quiz',
        preview_url: 'https://google.com',
      },
    }

    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['online_quiz'],
      submissionProps: sub,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders a discussion_topic submission', () => {
    let sub = {
      ...defaultSub,
      submission: {
        submission_type: 'discussion_topic',
        preview_url: 'https://google.com',
      },
    }

    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['discussion_topic'],
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
      assignmentSubmissionTypes: ['online_text_entry'],
      submissionProps: defaultSub,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders grade-only submission', () => {
    let sub = {
      ...defaultSub,
      submission: {
        attempt: null,
        submission_type: null,
        workflow_state: 'graded',
      },
    }

    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['online_text_entry'],
      submissionProps: sub,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders submission type of none', () => {
    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['none'],
      submissionProps: defaultSub,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders external tool submission', () => {
    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['external_tool'],
      submissionProps: defaultSub,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders external tool submission with a submission', () => {
    let sub = {
      ...defaultSub,
      submission: {
        submission_type: 'external_tool',
      },
    }

    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['external_tool'],
      submissionProps: sub,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders on-paper submission', () => {
    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['on_paper'],
      submissionProps: defaultSub,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders a file (stub)', () => {
    let sub = {
      ...defaultSub,
      submission: {
        submission_type: 'online_text_entry',
        body: '<p>Form Voltron</p>',
        attachments: [
          { fake: 'file' },
        ],
      },
    }
    let props = {
      selectedIndex: null,
      selectedAttachmentIndex: 0,
      assignmentSubmissionTypes: ['file_upload'],
      submissionProps: sub,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
