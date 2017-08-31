// @flow

declare var require: typeof require & { requireActual: (string) => any }

declare var jest: any

declare var fail: Function

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
