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

export default function parseLinkHeader (header: ?string) {
  const links: { [string]: ?string } = {}
  for (const link of (header || '').split(',')) {
    const parts = link.split(';').map(s => s.trim())

    if (!parts[0].startsWith('<') || !parts[0].endsWith('>')) continue
    const url = parts[0].slice(1, -1)

    for (const param of parts.slice(1)) {
      let [ key, value ] = param.split('=').map(s => s.trim())
      value = value.replace(/^"([^"]*)"$/, '$1').replace(/^'([^']*)'$/, '$1')
      if (key === 'rel') links[value] = url
    }
  }

  return Object.keys(links).length > 0 ? links : null
}
