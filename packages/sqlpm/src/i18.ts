// Not leveraging suggested Typescript approach to keep it simple
// https://www.i18next.com/overview/typescript
// See https://github.com/i18next/i18next-fs-backend

import i18n from 'i18next';
import FsBackend, {
  FsBackendOptions,
} from 'i18next-fs-backend';
import { join } from 'path';

let isSetup = false;

const i18nSetup = () => {
  i18n
    .use(FsBackend)
    .init<FsBackendOptions>({
      debug: false,
      initImmediate: false,
      fallbackLng: 'en',
      lng: 'en',
      ns: ['common'],
      defaultNS: 'common',
      backend: {
        loadPath: join(__dirname, './locales/{{lng}}/{{ns}}.json'),
      },
    });
};

const t = (key: string): string => {
  if (!isSetup) {
    i18nSetup();
    isSetup = true;
  }
  return i18n.t(key);
};

export default t;
