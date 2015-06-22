# Load modules, set start time:
from time import strftime, localtime
start_time = strftime('%a, %d %b %Y %H:%M:%S', localtime())
print start_time

# Set paths and file names:
output_dir = 'e:/field_boundaries'
output_gdb = 'fields.gdb'
error_file = open('e:/field_boundaries/errors.txt', 'w')

# Set scripting environment:
import arcgisscripting
gp = arcgisscripting.create()
gp.toolbox = 'management'

# Create geodatabase and make layer out of plss fc:
gp.CreateFileGDB(output_dir, output_gdb)
gp.MakeFeatureLayer('Database Connections\plss.sde\plss.acres_10', 'plss_10_lyr')

# Read list of fields to process:
file = open(output_dir + '/field_list.txt')

# Join views and plss fc, dissolve, add and populate field_kid and approxacres columns:
for line in file:
	fieldname = line.strip()
	try:
		#gp.CopyRows('Database Connections/plss.sde/plss.' + fieldname, 'Database Connections/plss.sde/plss.TBL' + fieldname)
		#fieldname = 'TBL' + fieldname
		gp.AddJoin('plss_10_lyr', 'recnmbr', 'Database Connections/plss.sde/plss.' + fieldname, 'plss_recnmbr', 'keep_common')
		gp.Dissolve('plss_10_lyr', output_dir + '/' + output_gdb + '/' + fieldname, 'plss.' + fieldname + '.field_kid', 'plss.' + fieldname + '.field_kid first;plss.' + fieldname + '.field_name first;plss.' + fieldname + '.produces_gas first;plss.' + fieldname + '.produces_oil first;plss.' + fieldname + '.status first;plss.' + fieldname + '.polydate first;plss.' + fieldname + '.cummulative_oil first;plss.' + fieldname + '.last_oil_production first;plss.' + fieldname + '.max_oil_wells first;plss.' + fieldname + '.last_oil_wells first;plss.' + fieldname + '.cummulative_gas first;plss.' + fieldname + '.last_gas_production first;plss.' + fieldname + '.max_gas_wells first;plss.' + fieldname + '.last_gas_wells first;plss.' + fieldname + '.avg_depth first;plss.' + fieldname + '.avg_depth_sealevel first', 'single_part')
		gp.AddField(output_dir + '/' + output_gdb + '/' + fieldname, 'FIELD_KID', 'text', '#', '#', '25', 'FIELD_KID', 'nullable', 'non_required', '#')
		gp.CalculateField(output_dir + '/' + output_gdb + '/' + fieldname, 'field_kid', '[first_plss_' + fieldname + '_field_kid]')
		gp.AddField(output_dir + '/' + output_gdb + '/' + fieldname, 'APPROXACRE', 'long', '#', '#', '#', 'APPROXIMATE_ACRES', 'nullable', 'non_required', '#')
		gp.CalculateField(output_dir + '/' + output_gdb + '/' + fieldname, 'approxacre', '[acres_10_shape_area]/4046.85643005')
		gp.DeleteField(output_dir + '/' + output_gdb + '/' + fieldname, 'plss_' + fieldname + '_field_kid;first_plss_' + fieldname + '_field_kid;first_plss_' + fieldname + '_field_name;first_plss_' + fieldname + '_produces_gas;first_plss_' + fieldname + '_produces_oil;first_plss_' + fieldname + '_status;first_plss_' + fieldname + '_polydate;first_plss_' + fieldname + '_cummulative_oil;first_plss_' + fieldname + '_last_oil_production;first_plss_' + fieldname + '_max_oil_wells;first_plss_' + fieldname + '_last_oil_wells;first_plss_' + fieldname + '_cummulative_gas;first_plss_' + fieldname + '_last_gas_production;first_plss_' + fieldname + '_max_gas_wells;first_plss_' + fieldname + '_last_gas_wells;first_plss_' + fieldname + '_avg_depth;first_plss_' + fieldname + '_avg_depth_sealevel')
		gp.RemoveJoin('plss_10_lyr', 'plss.' + fieldname)
	except:
		error_file = open('e:/field_boundaries/errors.txt', 'a')
		error_file.write(fieldname + '\n')
		msg = gp.getmessages()
		error_file.write(msg + '\n\n')
		error_file.close()
		gp.RemoveJoin('plss_10_lyr', 'plss.' + fieldname)
	print fieldname

########## Merge fields ##########
# Set workspace and output feature class name:
gp.workspace = 'e:/field_boundaries/fields.gdb'
out_fc = 'e:/field_boundaries/fields.gdb/fields'

# Create empty table to hold names of feature classes to be merged:
input_fcs = gp.CreateObject('ValueTable')

# Create a list of all feature classes in the geodatabase:
fcs = gp.ListFeatureClasses()
fc = fcs.Next()

# Load feature class names from list into table created above:
print 'Loading feature classes...'
while fc:
	input_fcs.AddRow(fc)
	fc = fcs.Next()

# Merge all feature classes in the table:
print 'Merging...'
gp.Merge(input_fcs, out_fc)

# Set end time:
end_time = strftime('%a, %d %b %Y %H:%M:%S', localtime())
print end_time
