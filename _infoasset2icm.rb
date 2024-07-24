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