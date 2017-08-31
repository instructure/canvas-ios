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

// @flow

import parseContextCode from './parse-context-code'

/*
 * Groups custom colors by their context type (course, account, group, etc).
 *
 * Example:
 *  const colors: CustomColors = {
 *    custom_colors: {
 *      course_1: '#fff',
 *      course_2: '#eee',
 *      account_1: '#ddd',
 *    }
 *  }
 *  groupCustomColors(colors)
 *
 * Result will be:
 *  {
 *    custom_colors: {
 *      course: {
 *        '1': '#fff',
 *        '2': '#eee',
 *      },
 *      account: {
 *        '1': '#ddd',
 *      },
 *    }
 *  }
 */
export default function groupCustomColors (colors: CustomColors): { [string]: { [string]: { [string]: string } } } {
  let result = {}
  for (const group in colors) {
    result[group] = {}
    for (const contextCode in colors[group]) {
      const parsed = parseContextCode(contextCode)
      result[group][parsed.type] = result[group][parsed.type] || {}
      result[group][parsed.type][parsed.id] = colors[group][contextCode]
    }
  }
  return result
}
