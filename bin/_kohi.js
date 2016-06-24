#!/usr/bin/env node
'use strict';
require( 'coffee-script/register' );
process.title = 'kohi';
require( __dirname + '/../lib/cli/cli' );

