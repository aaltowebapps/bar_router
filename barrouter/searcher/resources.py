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
        params = BASEPARAMS.copy()

        for key, value in request.GET.iteritems():
            params[key] = value
        r = requests.get(REITTIOPAS, params=params)
        j = json.loads(r.content)
        return j

