# IMPORT NODE DATA FROM A CSV FILE INTO ICM

## Import the 'date' library
require 'date'
WSApplication.use_arcgis_desktop_licence

## parameters
folder='C:/Users/HLewis/Downloads/infoasset2icm_wastewater_model/'
db=WSApplication.open('//10.0.29.43:40000/wastewater ongoing/system_performance',false)
nw = db.model_object_from_type_and_id('Model Network',4765)

## reserve network so no-one else can use it
nw.reserve

## Define a useful class
class ImportTable
	attr_accessor :in_table, :cfg_file, :csv_file, :cb_class

	def initialize(in_table, cfg_file, csv_file, cb_class)
		@in_table = in_table
		@cfg_file = cfg_file
		@csv_file = csv_file
		@cb_class = cb_class
	end
end

## Attribute Conversion from InfoAsset CSV Files into InfoWorks ICM

# Callback Classes
# Node - from InfoAsset manhole

class ImporterClassNode
	def ImporterClassNode.onBeginNode(obj)
		@systemTypeLookup={
			# original ones
			#'S' => 'storm', 'F' => 'foul',	'C' => 'combined', 'LD' => 'overland', 'Z' => 'other'
			'WWCO' => 'foul',
			'WWSC' => 'foul'
		}
		
		@nodeTypeLookup = {
			# original ones
			#'M' => 'manhole', 'G' => 'break', 'F' => 'outfall'
			'ACMH' => 'manhole',
			'LHCE' => 'break',
			'JOIN' => 'break',
			'ACDW' => 'storage',
			'TEE' => 'break',
			'ACSY' => 'break',
			'ACVP' => 'break',
			'METR' => 'break',
			'LATL' => 'break',
			'BEND' => 'break',
			'VALV' => 'break',
			'ACVL' => 'break',
			'PSTN' => 'storage',
			'TAPB' => 'break',
			'BNDY' => 'break',
			'HHLD' => 'break',
			'END' => 'manhole'
		}
	end
	
	def ImporterClassNode.onEndRecordNode(obj)
		icmSystemType = obj['system_type']
		icmNodeType = obj['node_type']
		
		if !icmSystemType.nil?
			icmSystemType = icmSystemType.downcase
		end
		
		if !icmNodeType.nil?
			icmNodeType = icmNodeType.downcase
		end
		
		if @systemTypeLookup.has_key? icmSystemType
			inNodeSystemType = @systemTypeLookup[icmSystemType]
		else
			inNodeSystemType = 'other'
		end
		
		if @nodeTypeLookup.has_key? icmNodeType
			inNodeNodeType = @nodeTypeLookup[icmNodeType]
		else
			inNodeNodeType = 'foul'
		end
		
		obj['node_type'] = inNodeNodeType
		obj['system_type'] = inNodeSystemType
		
	end
end

## Set up the config files and table names
import_tables = Array.new

import_tables.push ImportTable.new('Node', 
	folder + '/_csv2icm.cfg', 
	folder + '/exports/network.csv_cams_manhole.csv',
	ImporterClassNode)

puts "Import tables and config file setup"

##set options
options=Hash.new
#options['Error File'] = 'C:\Temp\ImportErrorLog.txt'		## String | blank | Path of error file
#options['Set Value Flag'] = 'CSV'							## String | blank | Flag used for fields set from data
#options['Default Value Flag'] = 'CSV'						## String | blank | Flag used for fields set from the default value column
#options['Image Folder'] = 'C:\Temp\'						## String | blank | Folder to import images from (Asset networks only)
#options['Duplication Behaviour'] = 'Merge'					## String | Merge | One of Duplication Behaviour:'Overwrite','Merge','Ignore'
#options['Units Behaviour'] = 'Native'						## String | Native | One of 'Native','User','Custom'
#options['Update Based On Asset ID'] = false				## Boolean | false
#options['Update Only'] = false								## Boolean | false
#options['Delete Missing Objects'] = false					## Boolean | false
#options['Allow Multiple Asset IDs'] = false				## Boolean | false
#options['Update Links From Points'] = false				## Boolean | false
#options['Blob Merge'] = false								## Boolean | false
#options['Use Network Naming Conventions'] = false			## Boolean | false
#options['Import images'] = false							## Boolean | false | Asset networks only
#options['Group Type'] = false								## Boolean | false | Asset networks only
#options['Group Name'] = false								## Boolean | false | Asset networks only
puts "specific import options defined"
	
## import tables into ICM
# Loop over table configs
import_tables.each{|table_info|
	
	options['Callback Class'] = table_info.cb_class
	
	# Do the import
	nw.odic_import_ex(
		'csv',					# import data format
		table_info.cfg_file,	# field mapping config file
		options,				# specified options override the default options
		table_info.in_table,	# import to ICM table name
		table_info.csv_file		# import from MapDrain table name
	)
}

puts 'End import'

## Commit changes and unreserve the network
nw.commit('Data imported from CSV')
nw.unreserve
puts 'Committed'