# main_script.rb

# EXPORT MODEL NETWORK AS CSV FILE

# ===========================================================================================
# parameters
net=WSApplication.current_network
net.clear_selection

net.run_SQL('Node', "
	SELECT 
	WHERE (
		status = 'INUS' OR 
		status = 'REPU' OR 
		status = 'STBY' OR 
		status = 'STOK' OR 
		status = 'END')
	AND (
		node_type <> 'ACBH' OR 
		node_type <> 'ACCL' OR 
		node_type <> 'ACDP' OR 
		node_type <> 'HHLD' OR 
		node_type <> 'END')
	")

# Set up params for exports
exp_options=Hash.new
exp_options['Use Display Precision'] = false		# Boolean | Default = true
exp_options['Flag Fields '] = false					# Boolean | Default = true
exp_options['Multiple Files'] = true				# Boolean | Default = false; Set to true to export to different files, false to export to the same file
exp_options['Selection Only'] = true				# Boolean | Default = false
#exp_options['Field Descriptions'] = false			# Boolean | Default = false
#exp_options['Field Names'] = true					# Boolean | Default = true
#exp_options['Native System Types'] = false			# Boolean | Default = false
#exp_options['User Units'] = false					# Boolean | Default = false
#exp_options['Object Types'] = false				# Boolean | Default = false
#exp_options['Units Text'] = false					# Boolean | Default = false

# String | Default = Packed. Either: Packed, None, or Separate
exp_options['Coordinate Arrays Format'] = 'None'	
exp_options['Other Arrays Format'] = 'Separate'
# Boolean | Default = false; Set to true to convert coordinate values into WGS84
exp_options['WGS84'] = false

# Export
net.csv_export(
	'C:\Users\HLewis\Downloads\infoasset2icm_wastewater_model\exports\network.csv', 
	exp_options
	)
	
net.clear_selection

# Run the second batch file
system('C:\Users\HLewis\Downloads\infoasset2icm_wastewater_model/_csv2icm.bat')