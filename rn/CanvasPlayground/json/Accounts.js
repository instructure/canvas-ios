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

import twilson from './twilson.json'
import mobiledev from './mobiledev.json'
import gbowden from './gbowden.json'

const accounts = [{
  domain: 'twilson.instructure.com',
  urls: twilson
},{
  domain: 'mobiledev.instructure.com',
  urls: mobiledev
},{
  domain: 'gbowden.instructure.com',
  urls: gbowden
}]

export default accounts
