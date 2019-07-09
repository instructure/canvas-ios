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

// @flow

const RealComponent = require.requireActual('../ZSSRichTextEditor')
const React = require('React')

export default class ZSSRichTextEditor extends React.Component<*> {
  render () {
    const props = { ...this.props, _setMock: this._setMock }
    return React.createElement('ZSSRichTextEditor', props, this.props.children)
  }

  _setMock = (ref: string, mock: any) => {
    this[ref] = mock
  }
}
ZSSRichTextEditor.propTypes = RealComponent.propTypes
