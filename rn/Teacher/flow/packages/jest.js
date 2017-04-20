// @flow

declare var require: typeof require & { requireActual: (string) => any }

declare var jest: any
jest

export const {
    afterAll,
    afterEach,
    beforeAll,
    beforeEach,
    describe,
    test,
    it,
    expect,
} = (global: any)
