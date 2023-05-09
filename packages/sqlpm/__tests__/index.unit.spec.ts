describe('index', () => {
  test('should call command when the module is loaded', () => {
    let mockedCommand;

    // We use jest.isolateModules to load the module in isolation, preventing
    // side effects from running when other tests are executed.
    jest.isolateModules(() => {
      jest.mock('../src/command', () => {
        mockedCommand = jest.fn();
        return {
          __esModule: true,
          default: mockedCommand,
        };
      });

      // eslint-disable-next-line global-require
      require('../src/index');
    });

    expect(mockedCommand).toHaveBeenCalled();
  });
});
