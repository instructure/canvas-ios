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

// @flow

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getPages (courseID: string): Promise<ApiResponse<Page[]>> {
  const url = `courses/${courseID}/pages`
  const options = {
    params: {
      per_page: 99,
    },
  }
  let pages = paginate(url, options)
  return exhaust(pages)
}

export function getPage (courseID: string, url: string): Promise<ApiResponse<Page>> {
  return httpClient().get(`courses/${courseID}/pages/${url}`)
}
