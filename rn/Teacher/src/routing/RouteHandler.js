//
// Copyright (C) 2018-present Instructure, Inc.
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

// @flow

export default class RouteHandler {
  template: string
  segments: string[]

  constructor (template: string) {
    this.template = template
    this.segments = template.split('/').filter(Boolean)
  }

  match (path: string): ?{ [string]: string } {
    let parts = path.replace(/^\/api\/v1/, '').split('/').filter(Boolean)
    let params = {}
    for (const segment of this.segments) {
      if (parts.length === 0) return
      if (segment[0] === '*') {
        params[segment.slice(1)] = parts.join('/')
        parts = []
      } else if (segment[0] === ':') {
        params[segment.slice(1)] = parts.shift()
      } else if (segment !== parts.shift()) {
        return
      }
    }
    if (parts.length !== 0) return
    return params
  }
}
