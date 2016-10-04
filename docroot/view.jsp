<%
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
%>

<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>

<portlet:defineObjects />

<style type="text/css">
#map_canvas {
    height: 500px;
    width: 400px
}
</style>
 
<script type="text/javascript">
	
    var <portlet:namespace />map;
    var <portlet:namespace />geocoder;
    var <portlet:namespace />directionDisplay;
    var <portlet:namespace />directionsService;
    var <portlet:namespace />rendererOptions = {
        draggable : true //make the map points draggable
    };
    var <portlet:namespace />initialLocation;
    var <portlet:namespace />infowindow;
 
    function <portlet:namespace />initialize() {
        var myLatlng = new google.maps.LatLng(-34.397, 150.644);
        var myLatlng2 = new google.maps.LatLng(-34.398, 150.645)
        var myOptions = {
        	//Nivel de zoom 1 mundo, 5 continentes	
            zoom : 1,
            center : myLatlng,
            mapTypeId : google.maps.MapTypeId.ROADMAP
        };
 
        <portlet:namespace />map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
        <portlet:namespace />geocoder = new google.maps.Geocoder();
        <portlet:namespace />directionsService = new google.maps.DirectionsService();
        <portlet:namespace />directionsDisplay = new google.maps.DirectionsRenderer(
                                                    <portlet:namespace />rendererOptions);
        <portlet:namespace />directionsDisplay.setMap(<portlet:namespace />map);
        <portlet:namespace />infowindow = new google.maps.InfoWindow();
 
        //geo location
        // Try W3C Geolocation method (Preferred)
        if (navigator.geolocation) {
            browserSupportFlag = true;
            navigator.geolocation.getCurrentPosition(function(position) {
                <portlet:namespace />initialLocation = new google.maps.LatLng(
                        position.coords.latitude, position.coords.longitude);
                contentString = "Location found using W3C standard";
                <portlet:namespace />map
                        .setCenter(<portlet:namespace />initialLocation);
                var marker = new google.maps.Marker({
                    map : <portlet:namespace />map,
                    position : <portlet:namespace />initialLocation
                });
                
                var marker2 = new google.maps.Marker({
                    position: myLatlng2,
                    map: <portlet:namespace />map,
                    title: 'Hello World!'
                  });
            }, function() {
                <portlet:namespace />handleNoGeolocation(browserSupportFlag);
            });
        } else if (google.gears) {
            // Try Google Gears Geolocation
            browserSupportFlag = true;
 
            var geo = google.gears.factory.create('beta.geolocation');
            geo.getCurrentPosition(function(position) {
                <portlet:namespace />initialLocation = new google.maps.LatLng(
                        position.latitude, position.longitude);
                contentString = "Location found using Google Gears";
                <portlet:namespace />map.setCenter(<portlet:namespace />initialLocation);
                <portlet:namespace />infowindow.setContent(contentString);
                <portlet:namespace />infowindow.setPosition(<portlet:namespace />initialLocation);
                <portlet:namespace />infowindow.open(<portlet:namespace />map);
            }, function() {
                <portlet:namespace />handleNoGeolocation(browserSupportFlag);
            });
        } else {
            // Browser doesn't support Geolocation
            browserSupportFlag = false;
            <portlet:namespace />handleNoGeolocation(browserSupportFlag);
        }
 
        //add listener for directions change
        google.maps.event.addListener(
            <portlet:namespace />directionsDisplay,
            'directions_changed',
            function() {
                var leg = <portlet:namespace />directionsDisplay.directions.routes[0].legs[0];
                Liferay.fire('directionsChanged', {
                        origin : leg.start_address,
                        destination : leg.end_address
                });
            });
    }
 
    function <portlet:namespace />handleNoGeolocation(errorFlag) {
        if (errorFlag == true) {
            <portlet:namespace />initialLocation = newyork;
            contentString = "Error: The Geolocation service failed.";
        } else {
            <portlet:namespace />initialLocation = siberia;
            contentString = "Error: Your browser doesn't support geolocation. Are you in Siberia?";
        }
        <portlet:namespace />map.setCenter(<portlet:namespace />initialLocation);
        <portlet:namespace />infowindow.setContent(contentString);
        <portlet:namespace />infowindow.setPosition(<portlet:namespace />initialLocation);
        <portlet:namespace />infowindow.open(<portlet:namespace />map);
    }
  
    function <portlet:namespace />loadScript() {
        var script = document.createElement("script");
        script.type = "text/javascript";
        script.src = "http://maps.google.com/maps/api/js?sensor=false&callback=<portlet:namespace />initialize";
        document.body.appendChild(script);
    }
 
    window.onload = <portlet:namespace />loadScript;
 
    function <portlet:namespace />showDirection(source, destination) {
        var request = {
            origin : source,
            destination : destination,
            travelMode : google.maps.DirectionsTravelMode.DRIVING
        };
        <portlet:namespace />directionsService.route(request, function(
                response, status) {
            if (status == google.maps.DirectionsStatus.OK) {
                <portlet:namespace />directionsDisplay.setDirections(response);
            }
        });
    }
 
    Liferay.on('planTravel', function(event) {
        <portlet:namespace />showDirection(event.origin, event.destination);
    });
</script>
 
<div id="map_canvas"></div>
