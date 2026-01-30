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
                fallback: 'index.html',
                strict: false
            })
            : adapterAuto(),
        paths: {
            base: isStatic ? '/cain-map-app' : ''
        }
    }
};

export default config;