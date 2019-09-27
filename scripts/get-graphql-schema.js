#!/usr/bin/env node

/*
Downloads the Canvas GraphQL schema and creates a schema file
outlining all of the union types for Apollo cache priming.

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