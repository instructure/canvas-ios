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

import 'react-native'
import React from 'react'
import CanvadocViewer from '../CanvadocViewer'
import renderer from 'react-test-renderer'

const templates = {
  ...require('../../../../__templates__/attachment'),
}

test('Canvadoc viewer renders', () => {
  let tree = renderer.create(
    <CanvadocViewer
      config={{ drawerInset: 0, previewPath: templates.attachment().preview_url }}
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
