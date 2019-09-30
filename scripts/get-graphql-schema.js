#!/usr/bin/env node
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

/*
Downloads the Canvas GraphQL schema and creates a schema file
outlining all of the union types for Apollo cache priming.

This script follows the Apollo docs found at the bottom of the page here
https://www.apollographql.com/docs/react/data/fragments/

Depends on node
 brew install node

Run this script from the repo root directory
 yarn graphql-schema
*/
const fs = require('fs')
const { execSync } = require('child_process')

const echo = (out) => console.log(out)
const run = (cmd) => execSync(cmd, { stdio: 'inherit' })

run(`curl -d ${JSON.stringify({
  variables: {},
  query: `
    {
      __schema {
        types {
          kind
          name
          possibleTypes {
            name
          }
        }
      }
    }
  `})}' -H "Content-Type: application/json" -X POST http://web.canvas.docker/api/graphql > tmp/graphql-schema.json`)

let schema = require('../tmp/graphql-schema.json')

// here we're filtering out any type information unrelated to unions or interfaces
const filteredData = schema.data.__schema.types.filter(
  type => type.possibleTypes !== null
)
schema.data.__schema.types = filteredData

fs.writeFile('rn/Teacher/src/canvas-api-v2/schema.json', JSON.stringify(schema.data), err => {
  if (err) {
    console.error('Error writing fragmentTypes file', err)
    return
  }

  console.log('Fragment types successfully extracted!')
})