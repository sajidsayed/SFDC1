var MapController = Class.create({
	initialize: function(initialAddress,mapElementId){
		this.initialAddress = initialAddress;
		this.mapElementId = mapElementId;
		this.map = new GMap2($(mapElementId));
		this.map.addControl(new GLargeMapControl());
		var isNew = $('p:f:isNew');
		if(isNew && 'false' == isNew.value){
			fireLocationFound();
			this.setPoint(new GLatLng($('p:f:latitude').value,$('p:f:longitude').value),true);
		} else {
			var geocoder = new GClientGeocoder();
			var countryCodeHint = $('p:f:countryCodeHint');
			if(countryCodeHint && countryCodeHint.value && !countryCodeHint.value.blank()){
				geocoder.setBaseCountryCode(countryCodeHint.value);
			}
			geocoder.getLatLng(
					this.initialAddress,
					function(point) {
						if (point) {
							fireLocationFound();
							this.setPoint(point,true);
						} else {
							fireLocationNotFound();
							this.setPoint(new GLatLng(37.4419, -122.1419),false);
						}
					}.bind(this)
				);
		}
		
	},
	setPoint: function(point, showMarker){
		this.map.setCenter(point,12);
		if(showMarker){
			var marker = new GMarker(point, {draggable: true});
			this.map.addOverlay(marker);
			this.handleMarkerMoved(marker);
			GEvent.addListener(marker, "dragend", function() {
				this.handleMarkerMoved(marker);
			}.bind(this));
		}
	},
	handleMarkerMoved: function(marker){
		$('p:f:longitude').value = marker.getLatLng().lng();
		$('p:f:latitude').value = marker.getLatLng().lat();
	}
});

document.observe('dom:loaded', function() {
	if($('map_canvas') && $('p:f:address')){
		try{
			new MapController($F('p:f:address'),'map_canvas');
		}catch(err){
            alert('Failed to load Google Maps.  If you\'re using Internet Explorer, please ensure the permission \'Display mixed content\' is set to \'Enable\'.');
		}
	}
}, false);
