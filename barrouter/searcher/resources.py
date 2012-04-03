from django.shortcuts import get_object_or_404
from piston.handler import BaseHandler
from piston.utils import validate, rc
import requests
#import base64
#import random
#import re

import json
#from datetime import datetime

REITTIOPAS = "http://api.reittiopas.fi/hsl/prod/"
USER = "aaltoreittiopas"
PASS = "m33p1qRA"
EPSG = "wgs84"

BASEPARAMS = {
    "user":USER,
    "pass":PASS,
    "epsg_in":EPSG,
    "epsg_out":EPSG
    }


def _error(error_type, message):
    error_type.write(message)
    return error

class QueryHandler(BaseHandler):
    allowed_methods = ('GET', )
    
    def read(self, request):
        try:
            longitude = request.GET["lon"]
            latitude = request.GET["lat"]
            to_location  = request.GET["to"]
        except:
            return _error(rc.BAD_REQUEST, "invalid parameters")

        params = BASEPARAMS.copy()
        params.update({
                "request": "reverse_geocode",
                "coordinate": str(longitude) + "," + str(latitude),
                })

        r = requests.get(REITTIOPAS, params=params)
        
        j = json.loads(r.content)
        return j


