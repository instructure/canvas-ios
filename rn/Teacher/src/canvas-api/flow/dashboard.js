//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

export type DashboardCardLink = {
  css_class: string,
  hidden: ?boolean,
  icon: string,
  label: string,
  path: string,
}

export type DashboardCard = {
  assetString: string,
  courseCode: string,
  enrollmentType: EnrollmentType,
  href: string,
  id: string,
  image: ?string,
  links: Array<DashboardCardLink>,
  longName: string,
  originalName: string,
  position: ?number,
  shortName: string,
  subtitle: string,
  term: ?CourseTerm,
}
