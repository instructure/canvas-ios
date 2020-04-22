//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import React from 'react'
import SubmissionViewer from '../SubmissionViewer'
import renderer from 'react-test-renderer'
import setProps from '../../../../test/helpers/setProps'

const templates = {
  ...require('../../../__templates__/submissions'),
  ...require('../../../__templates__/session'),
  ...require('../../../__templates__/helm'),
}

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
  beforeEach(() => {
    jest.clearAllMocks()
  })

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

  it('renders heic', () => {
    let url = 'https://fillmurray.com/200/200.heic'
    let sub = {
      ...defaultSub,
      submission: {
        attempt: 1,
        submission_type: 'online_upload',
        attachments: [
          { mime_class: 'image', url, 'content-type': 'image/heic' },
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

    let tree = shallow(<SubmissionViewer {...props} />)
    console.log(tree.debug())
    let viewer = tree.find('ImageSubmissionViewer')
    expect(viewer.prop('attachment').url).toEqual(url)
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

  it('navigates to urls in quizzes', () => {
    let sub = {
      ...defaultSub,
      submission: templates.submissionHistory([{
        submission_type: 'online_quiz',
        preview_url: 'https://canvas.instructure.com/courses/1/quizzes/2/preview',
      }]),
    }
    let props = {
      selectedIndex: null,
      selectedAttachmentIndex: 0,
      assignmentSubmissionTypes: ['online_quiz'],
      submissionProps: sub,
      isCurrentStudent: true,
      size: { width: 375, height: 667 },
      isModeratedGrading: false,
      drawerInset: 0,
      navigator: templates.navigator(),
    }
    let tree = shallow(<SubmissionViewer {...props} />)
    let webView = tree.find('AuthenticatedWebView')
    webView.simulate('Navigation', '/files/1/download')
    expect(props.navigator.show).toHaveBeenCalledWith('/files/1/download', {
      deepLink: true,
      modal: true,
    })
  })
})
