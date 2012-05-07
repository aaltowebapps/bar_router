from django.db import models
from searcher import reittiopas
import requests
import json

class Place(models.Model):
    name = models.CharField(max_length=256)
#    longitude = models.DecimalField(max_digits=12, decimal_places=10)
#    latitude = models.DecimalField(max_digits=12, decimal_places=10)
    latitude = models.CharField(max_length=16)
    longitude = models.CharField(max_length=16)
    updated = models.DateTimeField(auto_now_add=True)

    @staticmethod
    def create(geocode):
        lon, lat = geocode["coords"].split(",")
        return Place(name=geocode["name"], longitude=lon, latitude=lat)

    @staticmethod
    def get_or_fetch(name):
        places = Place.objects.filter(name=name)
        if places:
            return places[0]
        else:
            return Place.fetch(name)
        
    @staticmethod
    def fetch(name):
        params = reittiopas.BASEPARAMS.copy()
        params["request"] = "geocode"
        params["key"] = name
        r = requests.get(reittiopas.URL, params=params)
        j = json.loads(r.content)
        return Place.create(j[0])
        
    def encoded(self):
        return "%s,%s" % (self.longitude, self.latitude)
