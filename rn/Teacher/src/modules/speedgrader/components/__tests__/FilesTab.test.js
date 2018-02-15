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
import { FilesTab, mapStateToProps } from '../FilesTab'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'
import DrawerState from '../../utils/drawer-state'

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')

const templates = {
  ...require('../../../../__templates__/submissions'),
  ...require('../../../../__templates__/attachment'),
  ...require('../../../../redux/__templates__/app-state'),
}

let subWithAttachment = templates.submissionHistory([{
  id: '1',
  grade: null,
  submitted_at: '2017-04-26T17:46:00Z',
  submission_type: 'online_upload',
  attachments: [
    {
      id: '1234',
      mime_class: 'doc',
      thumbnail_url: null,
      display_name: 'cool file.doc',
    },
  ],
}])

let subWithManyAttachments = templates.submissionHistory([{
  id: '1',
  grade: null,
  submitted_at: '2017-04-26T17:46:00Z',
  submission_type: 'online_upload',
  attachments: [
    {
      id: '1234',
      mime_class: 'doc',
      thumbnail_url: null,
      display_name: 'cool file.doc',
    },
    {
      id: '1235',
      mime_class: 'image',
      thumbnail_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
      display_name: 'cool pic.jpg',
    },
    {
      id: '1236',
      mime_class: 'video',
      thumbnail_url: null,
      display_name: 'cool video.mp4',
    },
    {
      id: '1237',
      mime_class: 'audio',
      thumbnail_url: null,
      display_name: 'cool audio.mp3',
    },
    {
      id: '1238',
      mime_class: 'pdf',
      thumbnail_url: null,
      display_name: 'cool pdf.pdf',
    },
  ],
}])

let defaultSubmissionProps = {
  name: 'Allura',
  avatarURL: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
  status: 'submitted',
  userID: '4',
  grade: '5',
  submissionID: '1',
  submission: subWithAttachment,
}

let subPropsWithMany = {
  name: 'Allura',
  avatarURL: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
  status: 'submitted',
  userID: '4',
  grade: '5',
  submissionID: '1',
  submission: subWithManyAttachments,
}

let defaultProps = {
  closeModal: jest.fn(),
  showModal: jest.fn(),
  submissionID: '1',
  assignmentID: '2',
  courseID: '3',
  userID: '4',
  submissionProps: defaultSubmissionProps,
  selectFile: jest.fn(),
  selectedIndex: 0,
  selectedAttachmentIndex: null,
  drawerState: new DrawerState(),
}

let withIndex = {
  ...defaultProps,
  selectedAttachmentIndex: 1,
  submissionProps: subPropsWithMany,
}

let withZeroIndex = {
  ...defaultProps,
  selectedAttachmentIndex: 0,
}

let withURLSubmission = {
  ...defaultProps,
  submissionProps: {
    ...defaultSubmissionProps,
    attachments: [templates.attachment()],
    submission_type: 'online_url',
  },
}

describe('SpeedGraderFilesTab', () => {
  it('renders without a submission', () => {
    let props = {
      ...defaultProps,
      submissionID: null,
    }
    let tree = renderer.create(
      <FilesTab {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders with a submission', () => {
    let tree = renderer.create(
      <FilesTab {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders a selected non-zero index item', () => {
    let tree = renderer.create(
      <FilesTab {...withIndex} />
    )

    expect(tree).toMatchSnapshot()
  })

  it('renders a selected 0 index item', () => {
    let tree = renderer.create(
      <FilesTab {...withZeroIndex} />
    )

    expect(tree).toMatchSnapshot()
  })

  it('changes the selected file and closes drawer on tap', () => {
    const drawerState = new DrawerState()
    drawerState.snapTo = jest.fn()
    const props = {
      ...withIndex,
      drawerState,
    }
    let tree = renderer.create(
      <FilesTab {...props} />
    ).toJSON()

    const thirdRow = explore(tree).selectByID('speedgrader.files.row2') || {}
    thirdRow.props.onPress()
    expect(withIndex.selectFile).toHaveBeenCalled()
    expect(drawerState.snapTo).toHaveBeenCalledWith(0, true)
  })

  it('ignores attachments for URL Submissions', () => {
    let tree = renderer.create(
      <FilesTab {...withURLSubmission} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})

describe('mapStateToProps', () => {
  it('returns the correct data when there is no submission', () => {
    let state = templates.appState({
      entities: {
        submissions: {
          '1': {
            submission: {},
            pending: 0,
            error: null,
            selectedIndex: 3,
          },
        },
      },
    })

    let props = {
      ...defaultProps,
      submissionID: null,
    }

    let dataProps = mapStateToProps(state, props)
    expect(dataProps).toMatchObject({
      selectedAttachmentIndex: null,
    })
  })

  it('returns the correct data when there is a submission', () => {
    let state = templates.appState({
      entities: {
        submissions: {
          '1': {
            submission: {},
            pending: 0,
            error: null,
            selectedIndex: 1,
            selectedAttachmentIndex: 3,
          },
        },
      },
    })

    let dataProps = mapStateToProps(state, defaultProps)
    expect(dataProps).toMatchObject({
      selectedAttachmentIndex: 3,
    })
  })
})
