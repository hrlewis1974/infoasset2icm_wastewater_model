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
system(folder + '\_network.bat')