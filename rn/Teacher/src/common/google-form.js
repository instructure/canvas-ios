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

/*
 * A function that takes a set of answers and returns a uri for the
 * google form with the entry answers in the uri.
 *
 * Example:
 *   const entries = { favoriteColor: '1' }
 *   const form: GoogleForm = googleForm('https://docs.google.com/a', entries)
 *   const uri = form({ favoriteColor: 'blue' })
 *   => 'https://docs.google.com/a?entry.1=blue'
 */
type GoogleForm = (answers: { [string]: string }) => string

/*
 * Returns a GoogleForm configured with the given uri and entries
 */
export default function googleForm (uri: string, entries: { [string]: string }): GoogleForm {
  return (answers) => {
    const params = Object.keys(answers)
      .filter(key => answers[key])
      .map((key) => `entry.${entries[key]}=${answers[key]}`)
    return [uri, params.join('&')]
      .filter((s) => s.trim() !== '')
      .join('?')
      .replace(' ', '+')
  }
}
