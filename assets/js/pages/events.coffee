ko = window.ko
navigator = window.navigator

default_places = []

viewModel = 
   places: ko.observable()
   query: ko.observable()
   place_li_click: ( el ) ->
      url = '/places/details/'+this.reference
      $.getJSON url, ( res ) -> 
         console.log url, res
      
   geocode_search: ( el ) ->
      url = '/places/search/'+encodeURI( viewModel.query() )
      $.getJSON url, ( res ) ->
         viewModel.places clean_places( res )
         
viewModel.query.subscribe ( value )->
   if( value == '' )
      viewModel.places default_places
      #@TODO: fill this with a address string

clean_places = ( results )->
   places = results.results
   _.sortBy places, "vicinity"

getJunk = ( position ) ->
   $.getJSON '/places', position, ( res ) ->
      default_places = clean_places( res )
      viewModel.places default_places
      
locateThatGuyOrGirl = () ->
   if navigator.geolocation?
      navigator.geolocation.getCurrentPosition ( position ) ->
         getJunk
            lat: position.coords.latitude, 
            lon: position.coords.longitude
         
   else console.log "Woah man, you can't be located. You're off the grid. Mad props."

$(document).ready () ->
   ko.applyBindings viewModel
   
   locateThatGuyOrGirl()