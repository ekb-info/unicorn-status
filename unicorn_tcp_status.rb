#!/bin/env ruby

require 'rubygems'
require 'unicorn'

# Usage for this program
def usage
  puts "ruby unicorn_status.rb <path to unix socket> <poll interval in seconds> [number of iterations]"
  puts "Polls the given TCP socket every interval in seconds. Will not allow you to drop below 1 second poll intervals."
  puts "Example: ruby unicorn_tcp_status.rb 0.0.0.0:8887 10 6"
end

# Look for required args. Throw usage and exit if they don't exist.
if ARGV.count < 2
  usage
  exit 1
end

# Get the socket and threshold values.
socket = ARGV[0]
threshold = (ARGV[1]).to_i

# Check threshold - is it less than 1? If so, set to 1 seconds. Safety first!
if threshold.to_i < 1
  threshold = 1
end

if ARGV.count >= 2
  count = (ARGV[2]).to_i
else
  count = -1
end

# Poll the given socket every THRESHOLD seconds as specified above.
puts "Running infinite loop. Use CTRL+C to exit."
puts "------------------------------------------"
loop do
  Raindrops::Linux.tcp_listener_stats(socket).each do |addr, stats|
    puts "Run procs: " + `vmstat |grep -o '^ \\?[0-9]\\+'`.delete!("\n").to_i.to_s + "	HT queue: " + `./siblings.sh`.delete!("\n") + "	Active reqs: " + stats.active.to_s + "	Queued reqs: " + stats.queued.to_s 
  end
  sleep threshold
end
