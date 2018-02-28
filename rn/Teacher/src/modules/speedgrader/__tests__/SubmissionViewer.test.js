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

import React from 'react'
import SubmissionViewer from '../SubmissionViewer'
import renderer from 'react-test-renderer'
import setProps from '../../../../test/helpers/setProps'
import explore from '../../../../test/helpers/explore'

const templates = {
  ...require('../../../__templates__/submissions'),
  ...require('../../../__templates__/session'),
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
      drawerInset: 0,
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
      drawerInset: 0,
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
      drawerInset: 0,
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
      drawerInset: 0,
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
      drawerInset: 0,
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
      drawerInset: 0,
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
      drawerInset: 0,
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
        submission_type: 'basic_lti_launch',
        preview_url: 'https://googs.com/',
      },
    }

    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['external_tool'],
      submissionProps: sub,
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
      drawerInset: 0,
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
      drawerInset: 0,
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
      drawerInset: 0,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders an image using the ImageSubmissionViewer', () => {
    let sub = {
      ...defaultSub,
      submission: {
        submission_type: 'online_text_entry',
        body: '<p>Form Voltron</p>',
        attachments: [
          { mime_class: 'image', url: 'https://fillmurray.com/200/200' },
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
      drawerInset: 0,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(explore(tree).selectByType('ImageSubmissionViewer')).not.toBeNull()
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
      drawerInset: 0,
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
      drawerInset: 0,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders no group submission', () => {
    let props = {
      ...defaultSelections,
      assignmentSubmissionTypes: ['online_text_entry'],
      submissionProps: { ...defaultSub, groupID: '44' },
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
      drawerInset: 0,
    }

    let tree = renderer.create(
      <SubmissionViewer {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
