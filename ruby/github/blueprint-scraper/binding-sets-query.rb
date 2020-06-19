require "yaml"

$services = []
$sites = {} 

element='binding_sets'
puts "Finding all services with '#{element}'..."

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
        if service_def.has_key? element
          element_def = service_def[element]
          element_def.each do |registered_name, reg_name_def|
            reg_name_def.each do |registered_name_def| 
              if registered_name_def.has_key? 'sites'
                sites = registered_name_def['sites']
                $services.push([blueprint_name, system_name, service_name, service_def['type'], registered_name, sites])

                sites.each do |site|
                  if $sites.has_key? site
                    cnt = $sites[site] + 1
                  else
                    cnt = 1
                  end
                  $sites[site] = cnt
                end
              end  
            end
          end
        end
      end
    end
  rescue => e
    # Don't care, skipping malformed blueprint.
  end
end

puts "Found #{$services.size} services with '#{element}' and #{$sites.size} sites:"

puts
puts "detailed data for blueprints/systems with site"
$sites.each do |site, cnt|
  puts "#{site} | #{cnt}"
end
puts
puts "detailed data for blueprints/system/service/service types with binding_sets"
$services.each do |b, sys, srv, st, rn, s|
  puts "#{b} | #{st} | #{srv} | #{st} | #{rn} | #{s}"
end
