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

import { connect } from 'react-redux'
import CoursesActions from '../actions'
import refresh from '../../../utils/refresh'
import { Dashboard, mapStateToProps } from '../../dashboard/Dashboard'

export let Refreshed: any = refresh(
  props => props.refreshCourses(),
  props => props.courses.length === 0,
  props => Boolean(props.pending)
)(Dashboard)
export default connect(mapStateToProps(false), CoursesActions)(Refreshed)
