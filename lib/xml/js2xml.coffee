_ = require('underscore')

entitify = (str) ->
  str ?= ''
  str = '' + str
  str = str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/'/g, '&apos;').replace(/'/g, '&quot;')
  str

makeStartTag = (name, attr) ->
  attr = attr or {}
  tag = '<' + name
  for a of attr
    tag += ' ' + a + '=\"' + entitify(attr[a]) + '"'
  tag += '>'
  tag

makeEndTag = (name) ->
  '</' + name + '>'

makeElement = (name, data) ->
  element = ''
  if Array.isArray(data)
    data.forEach (v) ->
      element += makeElement(name, v)

    return element
  else if data? and typeof data is 'object'
    element += makeStartTag(name, data._attr)
    if data._value or data._value is ''
      element += entitify(data._value)
    else
      for el of data
        continue  if el is '_attr'
        element += makeElement(el, data[el])
    element += makeEndTag(name)
    return element
  else
    return makeStartTag(name) + entitify(data) + makeEndTag(name)
  throw 'Unknown data ' + data

xmlHeader = '<?xml version="1.0" encoding="utf-8"?>'

defaults =
  addXmlHeader: false

js2xml = (data, root, options) ->
  opts = _.extend(defaults, options)

  xml = ''
  xml += xmlHeader if opts.addXmlHeader
  xml += makeElement(root, data)
  xml

js2xml.entitify = entitify
js2xml.makeStartTag = makeStartTag
js2xml.makeEndTag = makeEndTag
js2xml.makeElement = makeElement
module.exports = js2xml