from django.conf.urls.defaults import patterns, include, url

from django.contrib.staticfiles.urls import staticfiles_urlpatterns

from django.conf import settings

from piston.resource import Resource

from searcher import resources


# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

query_handler = Resource(resources.QueryHandler)

urlpatterns = patterns('',
    url('^$', "searcher.views.index"),
    url('^api/query/$', query_handler),
    #url('^$', 'orgmap.views.index'),
)

if settings.DEBUG:
    urlpatterns += patterns('',
            url(r'^media/(?P<path>.*)$', 'django.views.static.serve', {
                'document_root': settings.MEDIA_ROOT,
                }),
            )
    urlpatterns += staticfiles_urlpatterns()
