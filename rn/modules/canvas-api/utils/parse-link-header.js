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
