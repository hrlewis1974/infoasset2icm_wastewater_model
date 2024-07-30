## Table of contents 

- [Purpose](#purpose)
- [Requirements](#requirements)
- [Workflow](#workflow)
- [Code](#code)
- [Recommendations](#recommendations)
- [Web](#web)
- [Contacts](#contacts)

## Applications

[![Autodesk](https://img.shields.io/badge/License-Autodesk-green.svg)](https://www.autodesk.com/nz)

## Purpose

This repository contains script and supporting files to assist in the conversion of an InfoAsset network to 
Infoworks ICM (InfoWorks network).

The purpose of this piece of work is to:

- remove the disconnect between the hydraulic models and asset data stored in InfoAsset
- enable a more robust model maintenance strategy for hydraulic model builds
- the intention from this point onwards is to maintain InfoAsset with the best available information such as pipe material, inverts and ground levels
- following some tidy up the base data it will then be possible to push changes such as new data/changed data and remove assets that have been deleted in InfoAsset

## Requirements

order | assumption | notes
--- | --- | ---
'1' | access to ICM Ultimate and ICM Exchange.exe | **version used: ICM 2024.5**
'2' | access to ICM Ultimate and iexchange.exe | **version used: InfoAsset 2021.8.1**
'3' | understanding on InfoAsset SQL | **good**
'4' | understanding on ICM | **good**
'5' | understading on Ruby Script | **good**

## Workflow

Currently the main Ruby script file "_infoasset2icm.rb" can be run on the active network ie the one open in the Geoplan.

On completion of the code a new network will be updated into:
- database: snumbat://10.0.29.43:40000/wastewater ongoing/system_performance
- network name='i2i network'
- network location='>other>networks>'
- network id=4765

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

- The is ruby script is to be run on the active network
- The first part of the script runs an SQL on the network
- This SQL effectively selects the network thats important for the hydraulic models
- The remainder of the SQL then pushes the selected network as CSV files to a folder

##### source GIS
<p align="left">
  <img src="https://github.com/hrlewis1974/infoasset2icm_wastewater_model/blob/8b46b291ee69ac4fb00f0dd558f77c9f39178b59/images/infoasset.JPG" width=800 />
</p>

```sql
/*  object type: all nodes and links
    purpose: select the network thats important 
    for the wastewater hydraulic model
*/

DESELECT ALL;

list $system_pw = 'PWDB', 'PWSC', 'PWST', 'PWTM', 'PWTP', 'RWST', 'RWTN';
list $system_sw = 'SWCO', 'SWSC', 'SWTD';
list $system_ww = 'WWCO', 'WWSC', 'WWST', 'WWTP';

list $system = 'WWCO';
list $status = 'INUS', 'REPU', 'STBY', 'STOK', 'END', 'VIRT';
list $type = 'ACBH', 'ACCL', 'ACDP', 'BNDY', 'HHLD', 'END';
list $pipe_type = 'DSCH_2', 'MAIN', 'TRNK';

SELECT ALL FROM [Node] IN Base SCENARIO 
WHERE MEMBER(status,$status)=TRUE
AND MEMBER(system_type,$system)=TRUE 
AND MEMBER(node_type,$type)=FALSE;

SELECT ALL FROM [Pipe] IN Base SCENARIO 
WHERE MEMBER(status,$status)=TRUE 
AND MEMBER(system_type,$system)=TRUE 
AND MEMBER(pipe_type,$pipe_type)=TRUE;

SELECT ALL FROM [Pump] IN Base SCENARIO 
WHERE MEMBER(status,$status)=TRUE;

SELECT ALL FROM [Screen] IN Base SCENARIO 
WHERE MEMBER(status,$status)=TRUE;

SELECT ALL FROM [Orifice] IN Base SCENARIO 
WHERE MEMBER(status,$status)=TRUE;

SELECT ALL FROM [Sluice] IN Base SCENARIO 
WHERE MEMBER(status,$status)=TRUE;

SELECT ALL FROM [Flume] IN Base SCENARIO 
WHERE MEMBER(status,$status)=TRUE;

SELECT ALL FROM [Siphon] IN Base SCENARIO 
WHERE MEMBER(status,$status)=TRUE;

SELECT ALL FROM [Weir] IN Base SCENARIO 
WHERE MEMBER(status,$status)=TRUE;

SELECT ALL FROM [Valve] IN Base SCENARIO 
WHERE MEMBER(status,$status)=TRUE;

DESELECT ALL FROM [All Nodes] 
WHERE count(ds_links.*)=0 
AND count(us_links.*)=0;
```

```ruby
# infoasset2icm.rb

# EXPORT MODEL NETWORK AS CSV AND TSV FILES

# ===========================================================================================
# parameters
folder = 'C:\Users\HLewis\Downloads\infoasset2icm_wastewater_model'

net=WSApplication.current_network
net.clear_selection

net.run_SQL('Node', "
	list $status = 'INUS', 'REPU', 'STBY', 'STOK', 'END', 'VIRT';
	list $type = 'ACBH', 'ACCL', 'ACDP', 'BNDY', 'HHLD', 'END';
	list $pipe_type = 'DSCH_2', 'MAIN', 'TRNK';

	SELECT ALL FROM [All Nodes] IN Base SCENARIO WHERE MEMBER(status,$status)=TRUE AND MEMBER(node_type,$type)=FALSE;
	SELECT ALL FROM [All Links] IN Base SCENARIO WHERE MEMBER(status,$status)=TRUE AND MEMBER(pipe_type,$pipe_type)=TRUE;
	SELECT ALL FROM [Pump] IN Base SCENARIO WHERE MEMBER(status,$status)=TRUE;
	SELECT ALL FROM [Screen] IN Base SCENARIO WHERE MEMBER(status,$status)=TRUE;
	SELECT ALL FROM [Orifice] IN Base SCENARIO WHERE MEMBER(status,$status)=TRUE;
	SELECT ALL FROM [Sluice] IN Base SCENARIO WHERE MEMBER(status,$status)=TRUE;
	SELECT ALL FROM [Flume] IN Base SCENARIO WHERE MEMBER(status,$status)=TRUE;
	SELECT ALL FROM [Siphon] IN Base SCENARIO WHERE MEMBER(status,$status)=TRUE;
	SELECT ALL FROM [Weir] IN Base SCENARIO WHERE MEMBER(status,$status)=TRUE;
	SELECT ALL FROM [Valve] IN Base SCENARIO WHERE MEMBER(status,$status)=TRUE;
	")

# Set up params
csv_options=Hash.new
csv_options['Use Display Precision'] = false
csv_options['Flag Fields '] = false
csv_options['Multiple Files'] = true
csv_options['Selection Only'] = true
csv_options['Coordinate Arrays Format'] = 'Packed'
csv_options['Other Arrays Format'] = 'Separate'
csv_options['WGS84'] = false
tsv_options = Hash.new
tsv_options['Export Selection'] = true

# Export CSV files
net.csv_export(folder + '\exports\csv\network.csv', csv_options)

# Export TSV files
## look through these .. later on
net.odec_export_ex('TSV', folder + '\infoasset2icm.cfg', tsv_options, 'Pump', folder + '\exports\tsv\pump.txt')
net.odec_export_ex('TSV', folder + '\infoasset2icm.cfg', tsv_options, 'Screen', folder + '\exports\tsv\screen.txt')
net.odec_export_ex('TSV', folder + '\infoasset2icm.cfg', tsv_options, 'Orifice', folder + '\exports\tsv\orifice.txt')
net.odec_export_ex('TSV', folder + '\infoasset2icm.cfg', tsv_options, 'Sluice', folder + '\exports\tsv\sluice.txt')
net.odec_export_ex('TSV', folder + '\infoasset2icm.cfg', tsv_options, 'Flume', folder + '\exports\tsv\flume.txt')
net.odec_export_ex('TSV', folder + '\infoasset2icm.cfg', tsv_options, 'Siphon', folder + '\exports\tsv\siphon.txt')
net.odec_export_ex('TSV', folder + '\infoasset2icm.cfg', tsv_options, 'Weir', folder + '\exports\tsv\weir.txt')
net.odec_export_ex('TSV', folder + '\infoasset2icm.cfg', tsv_options, 'Valve', folder + '\exports\tsv\valve.txt')

net.clear_selection

# Run the second batch file
#system(folder + '\_network.bat')
```

#### Run a batch file

- The last few lines of the above ruby script starts a batch file
- The batch file bascially starts and application ... ICMExchange.exe
- and passes the following ruby script for it to process

```bat
@echo off

set version=2024
if %version%==2024 (set "folder=Autodesk\InfoWorks ICM Ultimate 2024\ICMExchange.exe")

set bit=64
if %bit%==32 (set "path=C:\Program Files (x86)")
if %bit%==64 (set "path=C:\Program Files")

"%path%\%folder%" "%~dp0%\_network.rb"

PAUSE
```

#### Run a second Ruby script

- The final script picks up the InfoAsset exported network CSV files
- In conjunction with the InfoAsset fields it applies various lookup tables to create new fields
- the final set of data is then pushed to a network in an ICM model
- The push of data will append new rows, overwrite existing rows with changed data and delete and ones removed from InfoAsset

##### endpoint for  GIS
<p align="left">
  <img src="https://github.com/hrlewis1974/infoasset2icm_wastewater_model/blob/8b46b291ee69ac4fb00f0dd558f77c9f39178b59/images/icm_network.JPG" width=800 />
</p>

The following table was used as a template for each import class

<p align="left">
  <img src="https://github.com/hrlewis1974/infoasset2icm_wastewater_model/blob/da255bc3275dfdc8c5800b795671844978a9e550/images/schema_changes.jpg" width=800 />
</p>

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
	attr_accessor :tbl_format, :in_table, :cfg_file, :csv_file, :cb_class

	def initialize(tbl_format, in_table, cfg_file, csv_file, cb_class)
		@tbl_format = tbl_format
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
			'ACBH' => 'manhole',    #Bore Hole  (Well / Wellhead )
			'ACCL' => 'break',    	#Chlorination Point
			'ACDP' => 'break',    	#Cable Draw Point
			'ACDW' => 'manhole',    #Dry Well 
			'ACFM' => 'manhole',    #Flowmeter Chamber
			'ACMH' => 'manhole',    #Access Chamber Manhole
			'ACPU' => 'manhole',    #Pump Chamber
			'ACSY' => 'break',    	#Syphon Chamber 
			'ACVP' => 'break',    	#Vent Point
			'ACVU' => 'manhole',    #Vacuum Chamber / Pit
			'ACVX' => 'manhole',    #Vortex Chamber
			'ACWW' => 'manhole',    #Wet Well 
			'BEND' => 'break',    	#Bend
			'END' => 'manhole',    	#End
			'HHLD' => 'break',    	#Household
			'INGD' => 'gully',    	#Inlet Grated Open End
			'INND' => 'gully',    	#Inlet Open End
			'JOIN' => 'manhole',    #Join
			'LHCE' => 'break',    	#Lamphole Cleaning Eye
			'METR' => 'break',    	#Meter
			'OTGD' => 'gully',    	#Outlet Grated Open End
			'OTND' => 'gully',    	#Outlet Open End
			'PSTN' => 'manhole',    #Pump Station
			'RGDN' => 'manhole',    #Rain Garden
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

# Pipe - from InfoAsset Pipe
#
class ImporterClassPipe
	def ImporterClassPipe.onEndRecordConduit(obj)

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

		inSystemType = obj['system_type']
		
		if !inSystemType.nil?
			inSystemType = inSystemType#.upcase
		end
		
		if @systemTypeLookup.has_key? inSystemType
			icmPipeSystemType = @systemTypeLookup[inSystemType]
		else
			icmPipeSystemType = 'other'
		end
		
		obj['system_type'] = icmPipeSystemType
		
	end
end

# Pump - from InfoAsset Pump
#
class ImporterClassPump
	def ImporterClassPump.OnEndRecordPump(obj)
		
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
		
		obj['link_suffix'] = obj['id'][-1]
		
		inSystemType=obj['system_type']
		
		if !inSystemType.nil?
			inSystemType = inSystemType#.downcase
		end
		
		if @systemTypeLookup.has_key? inSystemType
			icmPipeSystemType = @systemTypeLookup[inSystemType]
		else
			icmPipeSystemType = 'other'
		end
		
		obj['system_type'] = icmPipeSystemType
		
		if obj['type'].upcase == 'F' 
			obj['link_type'] == 'FIXPMP'
		elsif obj['type'].upcase == 'V' 
			obj['link_type'] == 'VSPPMP'
		elsif obj['type'].upcase == 'V' 
			obj['link_type'] = 'VFDPMP'
		elsif obj['type'].upcase == 'R' 
			obj['link_type'] = 'ROTPMP'
		elsif obj['type'].upcase == 'S' 
			obj['link_type'] = 'SCRPMP'
		end
		
	end
end

# Screen - from InfoAsset Screen
#
class ImporterClassScreen
	def ImporterClassScreen.OnEndRecordScreen(obj)
		
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
		
		obj['link_suffix'] = obj['id'][-1]
		
		inSystemType=obj['system_type']
		
		if !inSystemType.nil?
			inSystemType = inSystemType#.downcase
		end
		
		if @systemTypeLookup.has_key? inSystemType
			icmPipeSystemType = @systemTypeLookup[inSystemType]
		else
			icmPipeSystemType = 'other'
		end
		
		obj['system_type'] = icmPipeSystemType
		
	end
end

# Orifice - from InfoAsset Orifice
#
class ImporterClassOrifice
	def ImporterClassOrifice.OnEndRecordOrifice(obj)
		
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
		
		obj['link_suffix'] = obj['id'][-1]
		
		inSystemType=obj['system_type']
		
		if !inSystemType.nil?
			inSystemType = inSystemType#.downcase
		end
		
		if @systemTypeLookup.has_key? inSystemType
			icmPipeSystemType = @systemTypeLookup[inSystemType]
		else
			icmPipeSystemType = 'other'
		end
		
		obj['system_type'] = icmPipeSystemType
		
	end
end

# Sluice - from InfoAsset Sluice
#
class ImporterClassSluice
	def ImporterClassSluice.OnEndRecordSluice(obj)
		
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
		
		obj['link_suffix'] = obj['id'][-1]
		
		inSystemType=obj['system_type']
		
		if !inSystemType.nil?
			inSystemType = inSystemType#.downcase
		end
		
		if @systemTypeLookup.has_key? inSystemType
			icmPipeSystemType = @systemTypeLookup[inSystemType]
		else
			icmPipeSystemType = 'other'
		end
		
		obj['system_type'] = icmPipeSystemType
		
	end
end

# Flume - from InfoAsset Flume
#
class ImporterClassFlume
	def ImporterClassFlume.OnEndRecordFlume(obj)
		
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
		
		obj['link_suffix'] = obj['id'][-1]
		
		inSystemType=obj['system_type']
		
		if !inSystemType.nil?
			inSystemType = inSystemType#.downcase
		end
		
		if @systemTypeLookup.has_key? inSystemType
			icmPipeSystemType = @systemTypeLookup[inSystemType]
		else
			icmPipeSystemType = 'other'
		end
		
		obj['system_type'] = icmPipeSystemType
		
	end
end

# Siphon - from InfoAsset Siphon
#
class ImporterClassSiphon
	def ImporterClassSiphon.OnEndRecordSiphon(obj)
		
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
		
		obj['link_suffix'] = obj['id'][-1]
		
		inSystemType=obj['system_type']
		
		if !inSystemType.nil?
			inSystemType = inSystemType#.downcase
		end
		
		if @systemTypeLookup.has_key? inSystemType
			icmPipeSystemType = @systemTypeLookup[inSystemType]
		else
			icmPipeSystemType = 'other'
		end
		
		obj['system_type'] = icmPipeSystemType
		
	end
end

# Weir - from InfoAsset Weir
#
class ImporterClassWeir
	def ImporterClassWeir.OnEndRecordWeir(obj)
		
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
		
		obj['link_suffix'] = obj['id'][-1]
		
		inSystemType=obj['system_type']
		
		if !inSystemType.nil?
			inSystemType = inSystemType#.downcase
		end
		
		if @systemTypeLookup.has_key? inSystemType
			icmPipeSystemType = @systemTypeLookup[inSystemType]
		else
			icmPipeSystemType = 'other'
		end
		
		obj['system_type'] = icmPipeSystemType
		
	end
end

## Set up the config files and table names
import_tables = Array.new

import_tables.push ImportTable.new(
	'csv', 'Node', 
	folder + '/_network.cfg', 
	folder + '/exports/csv/network.csv_cams_manhole.csv',
	ImporterClassNode)
	
import_tables.push ImportTable.new(
	'csv', 'Conduit', 
	folder + '/_network.cfg', 
	folder + '/exports/csv/network.csv_cams_pipe.csv',
	ImporterClassPipe)
	
import_tables.push ImportTable.new(
	'tsv', 'Pump', 
	folder + '/_network.cfg', 
	folder + '/exports/tsv/pump.txt',
	ImporterClassPump)

import_tables.push ImportTable.new(
	'tsv', 'Screen', 
	folder + '/_network.cfg', 
	folder + '/exports/tsv/screen.txt',
	ImporterClassScreen)

import_tables.push ImportTable.new(
	'tsv', 'Orifice', 
	folder + '/_network.cfg', 
	folder + '/exports/tsv/orifice.txt',
	ImporterClassOrifice)

import_tables.push ImportTable.new(
	'tsv', 'Sluice', 
	folder + '/_network.cfg', 
	folder + '/exports/tsv/sluice.txt',
	ImporterClassSluice)

import_tables.push ImportTable.new(
	'tsv', 'Flume', 
	folder + '/_network.cfg', 
	folder + '/exports/tsv/flume.txt',
	ImporterClassFlume)

import_tables.push ImportTable.new(
	'tsv', 'Siphon', 
	folder + '/_network.cfg', 
	folder + '/exports/tsv/siphon.txt',
	ImporterClassSiphon)

import_tables.push ImportTable.new(
	'tsv', 'Weir', 
	folder + '/_network.cfg', 
	folder + '/exports/tsv/weir.txt',
	ImporterClassWeir)
	
#import_tables.push ImportTable.new(
#	'tsv', 'User control', 
#	folder + '/_network.cfg', 
#	folder + '/exports/tsv/valve.txt',
#	'')

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
options['Update Links From Points'] = false					## Boolean | false
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
		table_info.tbl_format,	# input table format
		table_info.cfg_file,	# field mapping config file
		options,				# specified options override the default options
		table_info.in_table,	# import to ICM table name
		table_info.csv_file		# import from MapDrain table name
	)
}

puts 'End import'

## Commit changes and unreserve the network
nw.commit('Data imported from CSV and TSV files')
nw.unreserve
puts 'Committed'
```

## Recommendations

The above work has tested how data can be imported successfully from InfoAsset into ICM.

As part of the process the following recommendations should be applied to asset data updates in InfoAsset:

|action|description|
|---|---|
|&check;|work through process of importing InfoAsset data into Innovyze ICM|
|&check;|unique ID for the following assets needs to be made up of us_node_id and a sequential number: flume, orifice, pump, screen, siphon, sluice, valve and weir|
|&check;|link type for the above assets needs to be added to the 'standards and choice' list in InfoAsset. Its possible to adopt the same types used in the hydraulic modelling packages|
|&check;|ground levels in the original data should be saved as GPS_survey points. This way you'll have a record of the original levels before any corrections are made based on the latest ground models and or engineering judgement|
|&check;|invert levels should be converted to pipe depths... reason being the data would have been collected as depths at each manhole|
|&check;|where cover level and pipe depth data is available it is then possible to set the pipe invert flag to #D ... in doing so InfoAsset will work out the correct invert level|
|&cross;|in the first instance asset data for ancillaries should be populated from the hydraulic models|
|&cross;|change some valves to flaps to make the import of these assets into ICM easier....besides they are a form of flap valve|
|&check;|change system types so the SQL only selects assets required for the model|
|&cross;|add nodes to the tsv export routine and add extra fields using SQL which pick up ds_link system_type, pipe_type etc|
 
## Web

- [my github front page](https://github.com/hrlewis1974)
- [How do I import an InfoWorks ICM Model into InfoAsset Manager?](https://github.com/innovyze/Open-Source-Support/tree/main/02%20InfoAsset%20Manager/01%20Ruby/0003%20Import%20an%20InfoWorks%20ICM%20Model%20into%20InfoAsset%20Manager)
- [InfoAsset and ICM Exchange language](https://help.autodesk.com/lessons/IWICMS_2024_ENU/files/Exchange.pdf)

## Contacts

council | contact | email | contact details
--- | --- | --- | ---
WWL | Hywel Lewis | hywel.lewis@wellingtonwater.co.nz | Snr Hydraulic Modeller