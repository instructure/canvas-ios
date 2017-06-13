// @flow

import React from 'react'
import SubmissionViewer from '../SubmissionViewer'
import renderer from 'react-test-renderer'
import setProps from '../../../../test/helpers/setProps'

const templates = {
  ...require('../../../api/canvas-api/__templates__/submissions'),
}

jest
  .mock('WebView', () => 'Webview')

let defaultSelections = {
  selectedIndex: null,
  selectedAttachmentIndex: 0,
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
      submission: templates.submissionHistory([{
        submission_type: 'online_text_entry',
        body: '<p>Form Voltron</p>',
      }]),
    }

    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['online_text_entry'],
      submissionProps: sub,
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders an online_quiz submission', () => {
    let sub = {
      ...defaultSub,
      submission: templates.submissionHistory([{
        submission_type: 'online_quiz',
        preview_url: 'https://google.com',
      }]),
    }

    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['online_quiz'],
      submissionProps: sub,
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders a discussion_topic submission', () => {
    let sub = {
      ...defaultSub,
      submission: templates.submissionHistory([{
        submission_type: 'discussion_topic',
        preview_url: 'https://google.com',
      }]),
    }

    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['discussion_topic'],
      submissionProps: sub,
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
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
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
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
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
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
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
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
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
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
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
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
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
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
      assignmentSubmissionTypes: ['online_upload'],
      submissionProps: sub,
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders a media submission', () => {
    let sub = {
      ...defaultSub,
      submission: templates.submissionHistory([{
        submission_type: 'media_recording',
        media_comment: { url: 'https://instructuremedia.com/charlie_the_unicorn' },
      }]),
    }

    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['online_text_entry'],
      submissionProps: sub,
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
    }

    let component = renderer.create(
      <SubmissionViewer {...props} />
    )

    let tree = component.toJSON()
    expect(tree).toMatchSnapshot()

    const pause = jest.fn()
    const instance = component.getInstance()
    instance.videoPlayer = { pause }
    setProps(component, { ...props, isCurrentStudent: false })
    expect(pause).toHaveBeenCalled()
  })

  it('renders a moderated graded assignment submission', () => {
    let sub = {
      ...defaultSub,
      submission: templates.submissionHistory([{
        submission_type: 'online_text_entry',
      }]),
    }

    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['online_text_entry'],
      submissionProps: sub,
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: true,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
