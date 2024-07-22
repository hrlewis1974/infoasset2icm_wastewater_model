# EXPORT MODEL NETWORK AS CSV FILE

# ===========================================================================================
# parameters
dbase='//10.106.2.52:40000/InfoNet_Pims'

WSApplication.use_arcgis_desktop_licence
net=WSApplication.open(dbase,false)

# pick out network
mo = net.model_object_from_type_and_id('Collection Network',8170)

# Set up params for exports
exp_options=Hash.new
exp_options['Use Display Precision'] = false		# Boolean | Default = true
exp_options['Field Descriptions'] = false			# Boolean | Default = false
exp_options['Field Names'] = true					# Boolean | Default = true
exp_options['Flag Fields '] = false					# Boolean | Default = true
exp_options['Multiple Files'] = true				# Boolean | Default = false; Set to true to export to different files, false to export to the same file
exp_options['Native System Types'] = false		# Boolean | Default = false
exp_options['User Units'] = false					# Boolean | Default = false
exp_options['Object Types'] = false				# Boolean | Default = false
exp_options['Selection Only'] = false				# Boolean | Default = false
exp_options['Units Text'] = false					# Boolean | Default = false

# String | Default = Packed. Either: Packed, None, or Separate
exp_options['Coordinate Arrays Format'] = 'None'	
exp_options['Other Arrays Format'] = 'Separate'
# Boolean | Default = false; Set to true to convert coordinate values into WGS84
exp_options['WGS84'] = false

# Export
mo.csv_export(
	'C:\Users\HLewis\Downloads\infoasset2icm_wastewater_model\exports\network.csv', 
	exp_options
	)