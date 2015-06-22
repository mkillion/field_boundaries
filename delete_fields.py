from time import strftime, localtime
start_time = strftime('%a, %d %b %Y %H:%M:%S', localtime())
print start_time

working_dir = 'e:/field_boundaries'
changed_list = 'changed_fields.txt'
fields_fc = 'FIELDS'

import arcgisscripting
gp = arcgisscripting.create()
gp.toolbox = 'management'
gp.MakeFeatureLayer('Database Connections\plss.sde\plss.OILGAS_FIELDS_LAM', 'fields_lyr')

# Delete fields that have changed since the last update:
file = open(working_dir + '/' + changed_list)
for line in file:
	kid = line.strip()
	query = 'field_kid = ' + kid
	gp.SelectLayerByAttribute("fields_lyr", "ADD_TO_SELECTION", query)
count = gp.GetCount_management("fields_lyr")
print count
gp.DeleteFeatures('fields_lyr')

end_time = strftime('%a, %d %b %Y %H:%M:%S', localtime())
print end_time
