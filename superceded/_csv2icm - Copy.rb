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
puts "Connected to network: " + network

# Set up the config files and table names
import_tables = Array.new

# import_tables.push ImportTable.new('<InfoAsset Table Name>', '<Configuration File Name>.cfg', '<CSV File Name>', <Callback Class>)
import_tables.push ImportTable.new(
	'Node', 
	ImportFolder + '/config.cfg', 
	ImportFolder + '/model_node.csv', 
	ImporterClassNode)
	
#set options
#
options=Hash.new

options['Allow Multiple Asset IDs'] = false
options['Blob Merge'] = false
options['Delete Missing Objects'] = false
options['Update Based On Asset ID'] = false
options['Update Only'] = false
options['Update Links From Points'] = false
options['Use Network Naming Conventions'] = false
options['Error File'] = ImportFolder + '/ERROR.txt'
options['Default Value Flag'] = 'DV'
options['Set Value Flag'] = 'CV'
options['Duplication Behaviour'] = 'Overwrite'
options['Units Behaviour'] = 'Native'

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#

net = WSApplication.current_network

if !ImportFolder.nil?
	
	import_tables.each{|table_info| # Loop over table configs
		
		options['Callback Class'] = table_info.cb_class
		
		# Do the import
		net.odic_import_ex(	'csv',										# import data format
							table_info.cfg_file,						# field mapping config file
							options,									# specified options override the default options
							table_info.in_table,						# import to InfoAsset table name
							table_info.csv_file							# import from MapDrain table name
		)
	}
	
	puts 'Import Completed'
end
	puts 'Check - ' + ImportFolder + '\ERROR.txt' + ' for any Import Errors'

end