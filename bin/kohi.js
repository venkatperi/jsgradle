#!/usr/bin/env node
'use strict';
require( 'coffee-script/register' );
process.title = 'hog';
var findup = require( 'findup-sync' );
var resolve = require( 'resolve' ).sync;
var basedir = process.cwd();
var appPath;

try {
  appPath = resolve( 'kohi', {basedir : basedir} );
} catch ( ex ) {
  appPath = findup( 'lib/cli.coffee' );

  // No install found!
  if ( !appPath ) {
    console.log( 'Unable to find local kohi.' );
    process.exit( 99 )
  }
}

//noinspection JSUnresolvedFunction
try {
  require( appPath )
}
catch ( err ) {
  console.log( err.message );
  process.exit( 98 );
}
