require 'toto'
require 'rack-rewrite'
require 'coderay'
require 'rack/codehighlighter'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

# Rack config
use Rack::Static, :urls => ['/css', '/images', '/favicon.ico'], :root => 'public'
use Rack::CommonLogger
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

if ENV['RACK_ENV'] == 'development'
  use Rack::ShowExceptions
end

# Rewrite to keep the Google juice
use Rack::Rewrite do
  r301 %r{(.*)}, 'http://portertech.ca$1', :if => Proc.new { |rack_env|
    rack_env['SERVER_NAME'] =~ /^www\./i
  }
  r301 '/phones-servers-user-experience', '/2010/07/19/phones-servers-and-user-experience/'
  r301 '/fantasy-cricket-the-infrastructure', '/2010/05/28/fantasy-cricket-on-the-rackspace-cloud/'
  r301 '/homebrew-rvm-awesome', '/2010/03/26/homebrew--rvm--awesome/'
  r301 '/perfumecom-on-ec2-part-1-of-3', '/2010/02/28/perfumecom-on-aws/'
  r301 %r{^(.*[^/])$}, '$1/', :not => '/index.xml'
end

use Rack::Codehighlighter, :coderay, :markdown => true, :element => "code", :pattern => /\A:::(\w+)\s+/

#
# Create and configure a toto instance
#
toto = Toto::Server.new do
  #
  # Add your settings here
  # set [:setting], [value]
  #
  set :author,    'Sean Porter'                # blog author
  set :title,     'PorterTech'                 # site title
  set :root,      'index'                      # page to loadon /
  set :date do |now|
    now.strftime("%B #{now.day.ordinal} %Y")   # date format for articles
  end
  set :markdown,  :smart                       # use markdown + smart-mode
  set :disqus,    'portertech'                 # disqus id, or false
  set :summary,   :max => 150, :delim => /~\n/ # length of article summary and delimiter
  set :ext,       'txt'                        # file extension for articles
  set :cache,     28800                        # cache duration, in seconds
  set :url,       'http://portertech.ca'       # blog url

  set :description, "Sean Porter's blog on system automation and administration."
end

run toto
