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
import { shallow } from 'enzyme'

import EditFile from '../EditFile'

const template = {
  ...require('../../../__templates__/file'),
}

describe('EditFile', () => {
  it('passes the correct props to EditItem', () => {
    const tree = shallow(
      <EditFile
        file={template.file()}
        fileID='12345'
        navigator={{
          show: () => {},
          dismiss: () => {},
          pop: () => {},
        }}
        onChange={() => {}}
        onDelete={() => {}}
      />
    )
    expect(tree).toMatchSnapshot()
  })
})
