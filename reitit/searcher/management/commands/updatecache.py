from django.core.management.base import BaseCommand
from datetime import timedelta
from datetime import datetime

import os

class Command(BaseCommand):
    args = "no args plz"
    help = "Updates appcache"
    cachefile = "/home/inopia/webapps/reitit_static/reitit.appcache"

    def handle(self, *args, **options):
        files = [
                "/static/js/app.js",
                "/static/icons/juna.gif",
                "/static/icons/ratikka.gif",
                "/static/icons/bussi.gif",
                "/static/icons/metro.gif",
                "/static/icons/walk.gif",
                "/static/loader.gif",
                "/static/favicon.ico",
                ]


#        for item in os.listdir("/home/inopia/webapps/reitit_static/lib/"):
#            files.append("/static/lib/" + item)


        s = "CACHE MANIFEST\n#%s\nCACHE:\n"
        for filu in files:
            s += filu + "\n"
        s = s % datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')

        s += "NETWORK:\n"
        s += "*\nhttp://*\nhttps://*\n"
        s += "/api/\n"

        with open(self.cachefile, "w") as cache:
            cache.write(s)
