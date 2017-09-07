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

/* @flow */

type LinkHeaderRel = {
  rel: ?string,
  url: ?string,
}

type LinkHeader = {
  current?: ?LinkHeaderRel,
  first?: ?LinkHeaderRel,
  next?: ?LinkHeaderRel,
  last?: ?LinkHeaderRel,
}

const DELIM_LINKS = ';'
const DELIM_LINK_PARAM = '='
const META_REL = 'rel'
const META_NEXT = 'next'
const META_CURRENT = 'current'
const META_FIRST = 'first'
const META_LAST = 'last'

function parseLink (link: string): ?LinkHeaderRel {
  const segments = link.split(DELIM_LINKS)
  if (segments.length < 2) {
    return null
  }

  let linkPart = segments[0].trim()
  if (!(linkPart[0] === '<' && linkPart[linkPart.length - 1] === '>')) {
    return null
  }
  linkPart = linkPart.substring(1, linkPart.length - 1)

  for (const segment of segments.slice(1, segments.length)) {
    const rel = segment.trim().split(DELIM_LINK_PARAM)
    if (rel.length < 2 || !(rel[0] === META_REL)) {
      return null
    }

    let relValue = rel[1]
    if (relValue.startsWith('"') && relValue.endsWith('"')) {
      relValue = relValue.substring(1, relValue.length - 1)
    }
    if (relValue.startsWith('\'') && relValue.endsWith('\'')) {
      relValue = relValue.substring(1, relValue.length - 1)
    }

    return {
      rel: relValue,
      url: linkPart,
    }
  }
}

export default function parseLinkHeader (link: ?string): ?LinkHeader {
  if (link == null) {
    return null
  }

  const header: LinkHeader = {}
  link.split(',').forEach((link) => {
    const parsed = parseLink(link.trim())
    if (parsed != null) {
      switch (parsed.rel) {
        case META_CURRENT:
          header.current = parsed
          break
        case META_NEXT:
          header.next = parsed
          break
        case META_FIRST:
          header.first = parsed
          break
        case META_LAST:
          header.last = parsed
          break
      }
    }
  })

  return Object.keys(header).length > 0 ? header : null
}
