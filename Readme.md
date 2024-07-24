## Table of contents

- [Purpose](#purpose)
- [Assumptions](#assumptions)
- [Workflow](#workflow)
- [Code](#cope)
- [Web](#web)
- [Contacts](#contacts)

## Applications

[![Autodesk](https://img.shields.io/badge/License-Autodesk-green.svg)](https://www.autodesk.com/nz)

## Purpose

This repository contains script and supporting files to assist in the conversion of an InfoAsset network to 
Infoworks ICM (InfoWorks network).

Currently the main Ruby script file "_infoasset2icm.rb" can be run on the active network ie the one open in the Geoplan.

On completion of the code a new network will be updated into:
- database: snumbat://10.0.29.43:40000/wastewater ongoing/system_performance
- network: name='i2i network', location='other..networks' and id=4765

## Assumptions

order | assumption | notes
--- | --- | ---
'1' | access to ICM Ultimate and ICM Exchange.exe | **version used: ICM 2024.5**
'2' | access to ICM Ultimate and iexchange.exe | **version used: InfoAsset 2021.8.1**
'3' | understanding on InfoAsset SQL | **good**
'4' | understanding on ICM | **good**
'5' | understading on Ruby Script | **good**

## Workflow

```mermaid
flowchart TD
    A[InfoAsset] -->|open network in geoplan| B(select: network>run ruby script>_infoasset2icm.rb)
    B --> C{wait a little}
    C -->|SQL| D[selects network in geoplan]
    C -->|_infoasset2icm.rb| E[exports network as CSV files]
    C -->|_csv2icm.rb| F[upodates CSV files into ICM network]
```

## Code

#### Run Ruby script in network currently open in an InfoAsset Geoplan

```ruby
# main_script.rb

# EXPORT MODEL NETWORK AS CSV FILE

# ===========================================================================================
# parameters
folder = 'C:\Users\HLewis\Downloads\infoasset2icm_wastewater_model'
net=WSApplication.current_network
net.clear_selection

net.run_SQL('Node', "
	list $status = 'INUS', 'REPU', 'STBY', 'STOK', 'END';
	list $type = 'ACBH', 'ACCL', 'ACDP', 'BNDY', 'HHLD', 'END';
	list $pipe_type = 'DSCH_2', 'MAIN', 'TRNK';

	SELECT ALL FROM [All Nodes] IN Base SCENARIO
	WHERE MEMBER(status,$status)=TRUE
	AND MEMBER(node_type,$type)=FALSE;

	SELECT ALL FROM [All Links] IN Base SCENARIO
	WHERE MEMBER(status,$status)=TRUE
	AND MEMBER(pipe_type,$pipe_type)=TRUE;
	")

# Set up params for csv exports
csv_options=Hash.new
csv_options['Use Display Precision'] = false
csv_options['Flag Fields '] = false
csv_options['Multiple Files'] = true
csv_options['Selection Only'] = true
#csv_options['Field Descriptions'] = true
#csv_options['Field Names'] = false
#csv_options['Native System Types'] = true
#csv_options['User Units'] = true
#csv_options['Object Types'] = true
#csv_options['Units Text'] = true
csv_options['Coordinate Arrays Format'] = 'Packed'
csv_options['Other Arrays Format'] = 'Separate'
csv_options['WGS84'] = false

# Export to CSV files
net.csv_export(
	folder + '\exports\network.csv', 
	csv_options)

# Set up params for GDB exports if needed
# however we are able to get the geometry from point_array
# so no need
params = Hash.new
#params['Error File'] = errorFile
params['Export Selection'] = true
#params['Report Mode'] = false
#params['Callback Class'] = Exporter
#params['Image Folder'] = nil
#params['Units Behaviour'] = 'Native'
#params['Append'] = false
#params['Previous Version'] = 0
#params['WGS84'] = false
#params['Don't Update Geometry'] = false

#net.odec_export_ex('GDB', folder + '\_infoasset2icm.cfg', params,
#    'Pipe', 'pipe', 'pipes', false, nil,
#	folder + '\exports\pipe.gdb'
#)

net.clear_selection

# Run the second batch file
system('C:\Users\HLewis\Downloads\infoasset2icm_wastewater_model/_csv2icm.bat')
```

#### Run a batch file

```bat
@echo off

set version=2024
if %version%==2024 (set "folder=Autodesk\InfoWorks ICM Ultimate 2024\ICMExchange.exe")

set bit=64
if %bit%==32 (set "path=C:\Program Files (x86)")
if %bit%==64 (set "path=C:\Program Files")

"%path%\%folder%" "%~dp0%\_csv2icm.rb"

PAUSE
```

#### Run a second Ruby script

```ruby
# IMPORT NETWORK DATA FROM CSV FILES INTO AN ICM NETWORK

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
			'PWDB' => 'water',    	#Potable Water Distribution
			'PWSC' => 'water',    	#Potable Water Service Connection
			'PWST' => 'water',    	#Potable Water Storage
			'PWTM' => 'water',    	#Potable Water Transmission
			'PWTP' => 'water',    	#Potable Water Treatment 
			'RWST' => 'water',    	#Raw Water Storage
			'RWTN' => 'water',    	#Raw Water Transfer
			'SWCO' => 'storm',    	#Stormwater Collection
			'SWSC' => 'storm',    	#Stormwater Service Connection
			'SWTD' => 'storm',    	#Stormwater Treatment Device
			'WWCO' => 'foul',    	#Wastewater Collection 
			'WWSC' => 'foul',    	#Wasterwater Service Connection
			'WWST' => 'foul',    	#Wastewater Storage
			'WWTP' => 'foul'     	#Wastewater Treatment 
		}
	
		@nodeTypeLookup = {		
			'ACBH' => 'storage',    #Bore Hole  (Well / Wellhead )
			'ACCL' => 'break',    	#Chlorination Point
			'ACDP' => 'break',    	#Cable Draw Point
			'ACDW' => 'storage',    #Dry Well 
			'ACFM' => 'manhole',    #Flowmeter Chamber
			'ACMH' => 'manhole',    #Access Chamber Manhole
			'ACPU' => 'storage',    #Pump Chamber
			'ACSY' => 'break',    	#Syphon Chamber 
			'ACVP' => 'break',    	#Vent Point
			'ACVU' => 'manhole',    #Vacuum Chamber / Pit
			'ACVX' => 'manhole',    #Vortex Chamber
			'ACWW' => 'storage',    #Wet Well 
			'BEND' => 'break',    	#Bend
			'END' => 'manhole',    	#End
			'HHLD' => 'break',    	#Household
			'INGD' => 'gully',    	#Inlet Grated Open End
			'INND' => 'gully',    	#Inlet Open End
			'JOIN' => 'break',    	#Join
			'LHCE' => 'break',    	#Lamphole Cleaning Eye
			'METR' => 'break',    	#Meter
			'OTGD' => 'gully',    	#Outlet Grated Open End
			'OTND' => 'gully',    	#Outlet Open End
			'PSTN' => 'storage',    #Pump Station
			'RGDN' => 'storage',    #Rain Garden
			'SMP1' => 'gully',    	#Sump Single Side Entry
			'SMP2' => 'gully',    	#Sump Double Side Entry
			'SMPD' => 'gully',    	#Sump Dome
			'TEE' => 'break',     	#Tee
			'VALV' => 'break'     	#Valve
		}
	end
	
	def ImporterClassNode.onEndRecordNode(obj)
		
		inNodeType = obj['node_type']
		inSystemType = obj['system_type']
		
		if !inNodeType.nil?
			inNodeType = inNodeType#.downcase
		end
		
		if !inSystemType.nil?
			inSystemType = inSystemType#.downcase
		end
				
		if @nodeTypeLookup.has_key? inNodeType
			icmNodeNodeType = @nodeTypeLookup[inNodeType]
		else
			icmNodeNodeType = 'manhole'
		end
		
		if @systemTypeLookup.has_key? inSystemType
			icmNodeSystemType = @systemTypeLookup[inSystemType]
		else
			icmNodeSystemType = 'other'
		end
		
		obj['node_type'] = icmNodeNodeType
		obj['system_type'] = icmNodeSystemType
		
	end
end

## Set up the config files and table names
import_tables = Array.new

import_tables.push ImportTable.new('Node', 
	folder + '/_csv2icm.cfg', 
	folder + '/exports/network.csv_cams_manhole.csv',
	ImporterClassNode)
	
import_tables.push ImportTable.new('Conduit', 
	folder + '/_csv2icm.cfg', 
	folder + '/exports/network.csv_cams_pipe.csv',
	'')

puts 'Import tables and config file setup'

puts 'Start import'

##set options
options=Hash.new
#options['Error File'] = 'C:\Temp\ImportErrorLog.txt'		## String | blank | Path of error file
#options['Set Value Flag'] = '#A'							## String | blank | Flag used for fields set from data
options['Default Value Flag'] = '#A'						## String | blank | Flag used for fields set from the default value column
#options['Image Folder'] = 'C:\Temp\'						## String | blank | Folder to import images from (Asset networks only)
options['Duplication Behaviour'] = 'Overwrite'				## String | Merge | One of Duplication Behaviour:'Overwrite','Merge','Ignore'
#options['Units Behaviour'] = 'Native'						## String | Native | One of 'Native','User','Custom'
#options['Update Based On Asset ID'] = false				## Boolean | false
#options['Update Only'] = false								## Boolean | false
options['Delete Missing Objects'] = true					## Boolean | false
#options['Allow Multiple Asset IDs'] = false				## Boolean | false
#options['Update Links From Points'] = false				## Boolean | false
#options['Blob Merge'] = true								## Boolean | false
#options['Use Network Naming Conventions'] = false			## Boolean | false
#options['Import images'] = false							## Boolean | false | Asset networks only
#options['Group Type'] = false								## Boolean | false | Asset networks only
#options['Group Name'] = false								## Boolean | false | Asset networks only
puts 'specific import options defined'
	
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
```

## Web

- [my github front page](https://github.com/hrlewis1974)
- [example of similar workflow](https://www.linkedin.com/pulse/converting-infosewer-model-icm-infoworks-network-using-dickinson/)
- [InfoAsset and ICM Exchange language](https://help.autodesk.com/lessons/IWICMS_2024_ENU/files/Exchange.pdf)

## Contacts

council | contact | email | contact details
--- | --- | --- | ---
WWL | Hywel Lewis | hywel.lewis@wellingtonwater.co.nz | Snr Hydraulic Modeller