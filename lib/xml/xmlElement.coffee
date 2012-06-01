js2xml = require('./js2xml')
_ = require('underscore')

class XmlElement
  # Default constructor
  #
  # Call super in child classes
  #
  # elementName - name of xml element
  # attributes - list of attributes for xml element in json format, optional
  constructor: (elementName, attributes) ->
    @elementName = elementName
    @elements = []
    @value = null
    @attributes = if attributes? then parseAttributes(attributes) else []

    @namespace = null

  parseAttributes = (attrsJson) ->
    tempAttrs = []
    for name, value of attrsJson
      tempAttrs.push(name: name, value: value)
    tempAttrs

  addNode = (root, element, namespace) ->
    if element instanceof XmlElement
      elementName = element.elementName
      model = element.prepareModel()
      elementNamespace = element.namespace
      if namespace is null and elementNamespace?
        addNamespace(model, elementNamespace)

      rootElement = root[elementName]
      # need to check if we have array of identical elements
      # js2xml requires this array
      if rootElement?
        if rootElement instanceof Array
          rootElement.push(model)
          root[elementName] = rootElement
        else
          array = [rootElement]
          array.push(model)
          root[elementName] = array
      else
        root[elementName] = model

  addNodes = (root, elements, namespace) ->
    for element in elements
      addNode(root, element, namespace)

  addNamespace = (root, namespace) ->
    if namespace?
      root['_attr'] = xmlns: namespace

  addElement: (element) ->
    @elements.push(element)

  addElements: (elements) ->
    @elements.push(element) for element in elements

  # Add attribute to xml element
  #
  # name - attributre name
  # value - attribute value
  addAttr: (name, value) ->
    @attributes.push(
      name: name
      value: value)

  # Returns json presentation of current xml element with all child elements
  prepareModel: ->
    model = {}
    model['_value'] = @value if @value?
    if @attributes.length > 0
      model['_attr'] = {}
      for attr in @attributes
        model['_attr'][attr.name] = attr.value
    if @elements.length > 0
      addNodes(model, @elements, @namespace)
    model

  # Returns xml string
  toXml: ->
    model = @prepareModel()
    addNamespace(model, @namespace)
    return js2xml(model, @elementName, @namespace)

  findElementIndex: (name) ->
    resultIndex = -1
    _.find(@elements, (el, index) ->
      if el.elementName is name
        resultIndex = index
        return resultIndex)
    resultIndex

  getElement: (name) -> _.find(@elements, (el) -> el.elementName is name)
  setElement: (name, value) ->
    index = @findElementIndex(name)
    if index >= 0
      @elements[index] = value
    else
      @addElement(value)

module.exports = XmlElement