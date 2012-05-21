#!/usr/bin/env python
# -*- coding: utf-8 -*-

from fabric.api import *
from fabric.contrib.files import exists

from django.utils.html import strip_spaces_between_tags

import re
import time
import os
import json

def _config():
    env.user = "inopia"
    env.home = "/home/inopia/"
    #pubkey authentication
    #env.key_filename = "/home/%s/.ssh/id_staging_rsa" % env.user
    env.hosts = ["reitit.info"]
    env.appdir = os.getcwd()
    env.staticdir = env.appdir + "/static"

    env.minifier = "yui-compressor -o"

    env.install_db = False
    env.install_app = False
    env.install_media = False
    env.install_static = True

    env.files = []

def production():
    _config()

def _static():
    env.files.append("static.tar.gz")
    env.install_static = True

def _app():
    env.files.append("application.tar.gz")
    env.install_app = True


def _update_cache():
    with cd("/home/inopia/webapps/reitit/reitit/"):
        run("""python2.7 manage.py updatecache""")

def deploy():
    _static()
    _app()
    _prepare_deploy()
    _put()
    _install()

def _prepare_deploy():
    """
    Collects all files needed for service and puts them to /tmp/.
    """

    local("rm -rf /tmp/reitit_deploy/")
    paths = ["/tmp/reitit_deploy/",
            "/tmp/reitit_deploy/webapps/",
            "/tmp/reitit_deploy/webapps/reitit/",
            "/tmp/reitit_deploy/webapps/reitit/reitit/",
            "/tmp/reitit_deploy/webapps/reitit_static/",]
    for path in paths:
        if not os.path.exists(path):
	    os.mkdir(path)


    os.chdir("/tmp/reitit_deploy/")

    # static
    if env.install_static:
        local("cp -r %s/* /tmp/reitit_deploy/webapps/reitit_static/" % env.staticdir)
	os.chdir("/tmp/reitit_deploy/webapps/reitit_static/")
            
        css = "var collated_stylesheets = '"

        cssdir = "css/"
        for filu in os.listdir(cssdir):
            if filu.endswith(".css") and filu != "responsive.css":
                # yui-compressor 2.4.2 has a bug that busts media queries so dont minify them
                local(env.minifier + " " + cssdir + filu + " " + cssdir + filu)
                with open(cssdir + filu) as cssfilu:
                    css += cssfilu.read()

        css += "';\n"

        lib = ""
        libdir = "lib/"
        for filu in ("jquery-1.7.1.min.js", "jqm-config.js", "jquery.mobile-1.1.0.min.js", "underscore-min.js", "backbone-min.js", "backbone.localStorage-min.js", "OpenLayers.mobile.js"):
            with open(libdir + filu) as libfile:
                lib += libfile.read()

        jsdir = "js/"
        views = ""
        app = "" 
        main = ""

        for filu in ("favorites.js", "models.js", "utils.js", "main.js", "reittiopas.js"):
            with open(jsdir + filu) as jsfile:
                local( env.minifier + " " + jsdir + filu + " " + jsdir + filu)
                if filu == "main.js":
                    main += jsfile.read() + "\n"
                else:
                    app += jsfile.read() + "\n"

        for filu in os.listdir(jsdir + "views/"):
            if filu.endswith(".js"):
                local( env.minifier + " " + jsdir +"views/" + filu + " " + jsdir + "views/" + filu)
                with open(jsdir + "views/" + filu) as jsfile:
                    views += jsfile.read() + "\n"


        templatedir = "templates/"
        templates = {}
        for template in os.listdir(templatedir):
            if template.endswith(".html"):
                with open(templatedir + template, "r") as filu:
                    name = template.partition(".")[0]
                    data = strip_spaces_between_tags(filu.read())
                    templates[name] = data
        
        with open(jsdir + "app.js", "w") as out:
            out.write(css + lib + views + app + "tpl.templates = " + json.dumps(templates) + ";\n" + main)
#        local( env.minifier + " " + jsdir + "app.js " + jsdir + "app.js")


        os.chdir("/tmp/reitit_deploy")
	cmd = """tar czf static.tar.gz --exclude='*.coffee' --exclude='*.sass' webapps/reitit_static/"""
	local(cmd)
	
    # application
    if env.install_app:
        local("cp -r %s/* /tmp/reitit_deploy/webapps/reitit/reitit/" % env.appdir)
        local("rm -rf /tmp/reitit_deploy/webapps/reitit/static/")

	os.chdir("/tmp/reitit_deploy/")

	cmd = """tar czf application.tar.gz webapps/reitit/"""
	local(cmd)

def _put():
    """
    Upload stuff to server.
    """
    for filu in env.files:
        if filu.startswith("media"):
            continue
	put("/tmp/reitit_deploy/%s" % filu, "/home/inopia/")

def _install():
    with cd("/home/inopia/"):

	appdir = "/home/inopia/webapps/reitit"
        staticdir = "/home/inopia/webapps/reitit_static"

	run(appdir + "/apache2/bin/stop")

	if env.install_app:
	    run("rm %s/reitit/* -rf" % appdir)
        if env.install_static:
            run("rm %s/* -rf" % staticdir)

	for filu in env.files:
	    run("tar xzf %s" % filu)
	
	with cd(appdir + "/reitit/"):
	#    run("python2.7 manage.py migrate viewer")
	    run("find settings.py -type f -exec sed -i 's/DEBUG = True/DEBUG = False/g' {} ';'")
	    with cd("templates"):
		run("find ./ -type f -exec sed -i 's/<!--remove//g' {} ';'")
		run("find ./ -type f -exec sed -i 's/remove-->//g' {} ';'")
    
        if env.install_static:
            _update_cache()

	run(appdir + "/apache2/bin/start")
