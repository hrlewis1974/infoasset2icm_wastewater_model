## Table of contents

- [Purpose](#purpose)
- [Assumptions](#assumptions)
- [Workflow](#workflow)
- [Data](#data)
- [Scope](#scope)
- [Web Links](#web)
- [Glossary](#glossary)

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

## Committed Works
<p align="left">
  <img src="https://github.com/hrlewis1974/ww_modelling_spec/blob/8006252826faec873267cad09ec6d0a3fc9916bc/images/sp_committed_works.png" width=800 />
</p>

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

#### Get all items

```http
  GET /api/items
```

| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `api_key` | `string` | **Required**. Your API key |

#### Get item

```http
  GET /api/items/${id}
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id`      | `string` | **Required**. Id of item to fetch |

#### add(num1, num2)

Takes two numbers and returns the sum.

## Web Links

- [my github front page]: https://github.com/hrlewis1974
- [example of similar workflow]: https://www.linkedin.com/pulse/converting-infosewer-model-icm-infoworks-network-using-dickinson/
- [InfoAsset and ICM Exchange language]: https://help.autodesk.com/lessons/IWICMS_2024_ENU/files/Exchange.pdf

## Contacts

council | contact | email | contact details
--- | --- | --- | ---
WWL | Hywel Lewis | hywel.lewis@wellingtonwater.co.nz | Snr Hydraulic Modeller

## Glossary

term | meaning
--- | ---
Ruby | Coding language