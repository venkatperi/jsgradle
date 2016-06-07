Q = require 'q'
P = require './P'

withPromise = ( f, args... ) ->
  p = new P()
  f.apply null, args...
  p.promise

eachAsync = ( arr, fn ) ->
  prev = Q(true)
  arr.forEach ( a ) ->
    prev = prev.then ->
      p = new P()
      fn a, p
      p.promise
  prev

all = ( arr, fn ) ->
  promises = []
  arr.forEach ( a ) ->
    p = new P()
    fn a, p
    promises.push p.promise

  Q.all promises

module.exports =
  eachAsync : eachAsync
  all : all
  runp : withPromise
  