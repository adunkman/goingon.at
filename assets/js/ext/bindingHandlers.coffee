handlers = window.ko.bindingHandlers
unwrap = window.ko.utils.unwrapObservable

handlers.parallax = do () ->
   elements = []

   $(document).mousemove (event) ->
      x = event.pageX
      y = event.pageY

      for element in elements
         if element.x isnt null
            for property of element.x
               factor = element.x[property]
               $(element.el).css(property, element.originalX + x * factor)
         
         if element.y isnt null
            for property of element.y
               factor = element.y[property]
               $(element.el).css(property, element.originalY + y * factor)

   return init: (element, valueAccessor) ->
      scales = unwrap valueAccessor() || {}
      scales.x or= null
      scales.y or= null

      if scales.x?
         for property of scales.x
            scales.originalX = parseInt $(element).css(property)

      if scales.y? 
         for property of scales.y
            scales.originalY = parseInt $(element).css(property)

      elements.push
         el: element,
         originalX: scales.originalX,
         x: scales.x,
         originalY: scales.originalY,
         y: scales.y