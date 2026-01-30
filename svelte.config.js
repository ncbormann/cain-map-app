import adapterAuto from '@sveltejs/adapter-auto';
import adapterStatic from '@sveltejs/adapter-static';

const isStatic = process.env.STATIC_BUILD === 'true';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  kit: {
    adapter: isStatic
      ? adapterStatic({
          pages: 'build',
          assets: 'build',
          fallback: 'index.html', // required for SPA routing on GH Pages
        })
      : adapterAuto(),

    paths: {
      base: isStatic ? '/YOUR_REPO_NAME' : '',
    }
  }
};

export default config;
