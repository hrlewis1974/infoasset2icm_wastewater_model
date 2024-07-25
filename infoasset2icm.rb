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

	SELECT ALL FROM [All Nodes] IN Base SCENARIO
	WHERE MEMBER(status,$status)=TRUE
	AND MEMBER(node_type,$type)=FALSE;

	list $pipe_type = 'DSCH_2', 'MAIN', 'TRNK';

	SELECT ALL FROM [All Links] IN Base SCENARIO
	WHERE MEMBER(status,$status)=TRUE
	AND MEMBER(pipe_type,$pipe_type)=TRUE;

	SELECT ALL FROM [Pump];
	SELECT ALL FROM [Weir];
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

## Export to CSV files
net.csv_export(
	folder + '\exports\csv\network.csv', 
	csv_options)

## Export to TSV files
net.odec_export_ex('TSV', 
	folder + '\infoasset2icm.cfg', 
	tsv_options, 
	'Pump', folder + '\exports\tsv\pump.txt'
)

net.clear_selection

# Run the second batch file
#system(folder + '\_network.bat')
#system(folder + '\_ancillaries.bat')