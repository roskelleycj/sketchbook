require "yaml"

$services = []

location = ARGV[0]
puts "Finding all services with location '#{location}'..."

Dir["fs-eng/*.yml"].each do |blueprint_filename|
  # puts blueprint_filename
  input_file = File.open(blueprint_filename, 'r')
  input_yml = input_file.read
  input_file.close

  begin
    blueprint = YAML::load(input_yml)
    next if blueprint['version'] == 0.3

    blueprint_name = blueprint['name']
    next if blueprint['deploy'].nil?

    systems = blueprint['deploy']
    systems.each do |system_name, services|
      services.each do |service_name, service_def|
        if service_def.has_key? 'location' and service_def['location'] =~ /#{location}/
          $services.push([service_def['location'], blueprint_name, system_name, service_name,service_def['type']])
        end
      end
    end
  rescue => e
    # Don't care, skipping malformed blueprint.
  end
end

puts "Found #{$services.size} services in '#{location}':"

$services.each do |loc, b, sys, srv, st|
  puts "#{loc} | #{b} | #{sys} | #{srv} | #{st}"
end
