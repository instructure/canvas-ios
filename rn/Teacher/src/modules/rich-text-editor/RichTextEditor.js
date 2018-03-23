//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

import React, { Component } from 'react'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import RCE, { type Props } from '../../common/components/rich-text-editor/RichTextEditor'

type OwnProps = Props & {
  onChangeValue?: (value: string) => void,
}

export default class RichTextEditor extends Component<OwnProps, any> {
  editor: ?RCE

  done = async () => {
    if (!this.editor) return
    const html = await this.editor.getHTML()
    this.props.onChangeValue && this.props.onChangeValue(html)
    this.props.navigator.dismiss()
  }

  render () {
    return (
      <Screen
        showDismissButton={false}
        leftBarButtons={[
          {
            title: i18n('Done'),
            testID: 'rich-text-editor.dismiss',
            style: 'done',
            action: this.done,
          },
        ]}
      >
        <RCE
          {...this.props}
          ref={(r) => { this.editor = r }}
        />
      </Screen>
    )
  }
}
