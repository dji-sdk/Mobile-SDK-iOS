#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'sinatra/streaming'
require 'json'
require 'tilt/erb'
# require 'pry-byebug'

set server: 'thin', connections: []
set :bind, '0.0.0.0'

ERROR_COLOR = '#D01B24'
WARN_COLOR  =  '#A57705'
DEBUG_COLOR = '#1E651E'
INFO_COLOR  = '#5859B7'
VERBOSE_COLOR = '#708183'
NOTIFICATION_COLOR = '#888'

put '/' do
  params = JSON.parse(request.body.read)
  if params["notification"]
    local_log = params["notification"]
    local_id = 'notification'
  elsif params["message"]
    local_log = params["message"]
    local_id = 'message'
  end

  if params["device_id"]
    device_id = params["device_id"]
  else
    device_id = 'NOT SET'
  end

  local_log.gsub! "\n", " "

  local_id = params["log_level"] if params["log_level"]

  time_stamp = Time.now.strftime("%b %d, %Y %H:%M:%S")

  final_str = "<tr id=\"#{local_id}\"><td id=\"device_id\">#{device_id}</td><td id=\"time_stamp\">#{time_stamp}</td><td id=\"time_stamp\">#{local_log}</td></tr>"

  settings.connections.each do |out|
    if out.device_id_filter
      out << "data: #{final_str}\n\n" if out.device_id_filter == device_id
    else
      out << "data: #{final_str}\n\n"
    end
  end
  204 #
end

get '/' do
  erb :logs, locals: {error_color: ERROR_COLOR, warn_color: WARN_COLOR , debug_color: DEBUG_COLOR, info_color: INFO_COLOR , verbose_color: VERBOSE_COLOR, notification_color: NOTIFICATION_COLOR}
end

get '/stream', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    class << out
      attr_accessor :device_id_filter
    end
    out.device_id_filter = params[:filter]
    out.callback { settings.connections.delete(out) }
  end
end

get '/jquery.js' do
  send_file("./jquery.js")
end

__END__

@@ layout
<html>
<head>
  <title>DJI Remote Log</title>
  <meta charset="utf-8" />
  <!-- // <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script> -->
  <script src="/jquery.js"></script>
  <style>
    table, th, td {
    border: 1px solid black;
    border-collapse: collapse;
  }
  th, td {
  padding: 15px;
}
#notification {
  color: <%= notification_color %>;
}
#message {
  color: <%= debug_color %>;
}
#Verbose {
  color: <%= verbose_color %>;
}
#Info {
  color: <%= info_color %>;
}
#Debug {
  color: <%= debug_color %>;
}
#Warn {
  color: <%= warn_color %>;
}
#Error {
  color: <%= error_color %>;
}
</style>
</head>
<body><%= yield %></body>
</html>

@@ logs

<table id='logsTable' style="min-width:300px">
  <thead>
    <tr>
     <th>Device ID</th>
     <th>Timestamp</th>
     <th>Log</th>
   </tr>
 </thead>
 <tbody>
 </tbody>
</table>

<script>
  // reading
  var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
    sURLVariables = sPageURL.split('&'),
    sParameterName,
    i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split('=');

      if (sParameterName[0] === sParam) {
        return sParameterName[1] === undefined ? true : sParameterName[1];
      }
    }
  };
  var es;
  var filter = getUrlParameter('filter');
  if (filter != null) {
    es = new EventSource('/stream?filter='+filter)
  }
  else {
    es = new EventSource('/stream');
  };
  es.onmessage = function(e) {
  	if (e.data != "") {
      $('#logsTable > tbody:last-child').append(e.data);
    };
  };
</script>
