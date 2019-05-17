// rollup.config.js
import nodeResolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';
// import babel from 'rollup-plugin-babel';
import json from 'rollup-plugin-json';
import copy from 'rollup-plugin-copy';

import uglify from "rollup-plugin-uglify-es";

export default [
  {
    input: 'src/main.js',
    output: [
      {
        file: 'dist/main.js',
        format: 'cjs',
      },
    ],
    plugins: [
      nodeResolve({jsnext: true}), // load npm modules from npm_modules
      json(), // avoid the package.json parsing issue
      commonjs(), // convert CommonJS modules to ES6
      // babel(), // convert to ES5
      uglify(),
      copy({
        targets:[
          'src/index.html',
          'src/main.css',
          'src/help.svg',
          'src/upload.svg'
        ],
        outputFolder:'dist'
      })
    ],
  }
]