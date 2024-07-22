# EXPORT MODEL NETWORK AS SHAPE FILES

# Import the 'date' library
require 'date'

# ===========================================================================================
# parameters
dbase='//10.0.29.43:40000/wastewater ongoing/system_performance'
working_dir = 'C:\\Users\\HLewis\\Downloads\\ww_model_system_performance\\icm_network'

array = [3695]
name = ['plimmerton_tank']
index = 0

WSApplication.use_arcgis_desktop_licence

net=WSApplication.open(dbase,false)
puts "Accessed: " + dbase

until index == array.length

	# pick out network
	mo = net.model_object_from_type_and_id('Model Network',array[index])
	
	# Set up params for exports
	params=Hash.new
	params['ExportFlags'] = false
	
	# Convert to string
	#string = index.to_s
	db_name = name[index]
	
	# Export
	mo.GIS_export('MIF',params,working_dir + '\\exports\\' + db_name)
	puts "exported network to GIS export folder"

	# Loop
	index += 1
end