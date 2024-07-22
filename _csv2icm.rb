# IMPORT NODE DATA FROM A CSV FILE INTO ICM

# Import the 'date' library
require 'date'

# parameters
dbase='//10.0.29.43:40000/wastewater ongoing/system_performance'
network=4765

WSApplication.use_arcgis_desktop_licence

net=WSApplication.open(dbase,false)
puts "Accessed database: " + dbase

mo = net.model_object_from_type_and_id('Model Network',network)
puts "Connected to network: " + network.to_s