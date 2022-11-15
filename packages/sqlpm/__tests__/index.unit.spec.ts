import sqlpm from '../src/index';

describe('sqlpm', () => {
  it('should return a defined', async () => {
    expect(sqlpm).toBeDefined();
    expect(sqlpm()).toEqual(1);
  });
});
