from django.shortcuts import render_to_response, get_object_or_404#, redirect
from django.template import RequestContext
from django.http import HttpResponse
from searcher import models
from searcher import reittiopas
import requests
import json

def index(request):
        return render_to_response("index.html", {}, context_instance=RequestContext(request))

def queryHandler(request):
    if request.method != "GET":
        return HttpResponse(status=405) #method not allowed
    
    params = reittiopas.BASEPARAMS.copy()

    for key, value in request.GET.iteritems():
        params[key] = value

    if params.get("request") == "route":
        params["from"] = models.Place.get_or_fetch(params["from"]).encoded()
        params["to"] = models.Place.get_or_fetch(params["to"]).encoded()

    r = requests.get(reittiopas.URL, params=params)
   
    if params.get("request") == "geocode":
        j = json.loads(r.content)
        models.Place.create(j[0])

    return HttpResponse(r.content, content_type="application/json")


