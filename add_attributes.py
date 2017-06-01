from time import strftime, localtime
start_time = strftime('%a, %d %b %Y %H:%M:%S', localtime())
print start_time

print 'Initializing...'

import arcgisscripting
gp = arcgisscripting.create()
gp.workspace = 'c:/field_boundaries/fields.gdb'
out_fc = 'c:/field_boundaries/fields.gdb/fields'

print 'Adding fields...'

gp.AddField(out_fc, 'FIELD_NAME', 'text', '#', '#', '150', 'FIELD_NAME', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'STATUS', 'text', '#', '#', '50', 'STATUS', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'FIELD_TYPE', 'text', '#', '#', '5', 'FIELD_TYPE', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'PROD_GAS', 'text', '#', '#', '3', 'PRODUCES_GAS', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'PROD_OIL', 'text', '#', '#', '3', 'PRODUCES_OIL', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'ACTIVEPROD', 'text', '#', '#', '10', 'ACTIVE_PRODUCTION', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'CUMM_OIL', 'float', '#', '#', '#', 'CUMMULATIVE_OIL', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'MAXOILWELL', 'float', '#', '#', '#', 'MAX_OIL_WELLS', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'LASTOILPRO', 'float', '#', '#', '#', 'LAST_OIL_PRODUCTION', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'LASTOILWEL', 'float', '#', '#', '#', 'LAST_OIL_WELL_COUNT', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'LASTODATE', 'text', '#', '#', '50', 'LAST_OIL_DATE', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'CUMM_GAS', 'float', '#', '#', '#', 'CUMMULATIVE_GAS', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'MAXGASWELL', 'float', '#', '#', '#', 'MAX_GAS_WELLS', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'LASTGASPRO', 'float', '#', '#', '#', 'LAST_GAS_PRODUCTION', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'LASTGASWEL', 'float', '#', '#', '#', 'LAST_GAS_WELL_COUNT', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'LASTGDATE', 'text', '#', '#', '50', 'LAST_GAS_DATE', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'AVGDEPTH', 'float', '#', '#', '#', 'AVG_DEPTH', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'AVGDEPTHSL', 'float', '#', '#', '#', 'AVG_DEPTH_SEALEVEL', 'nullable', 'non_required', '#')
gp.AddField(out_fc, 'POLYDATE', 'date', '#', '#', '#', 'POLYGON_CREATION_DATE', 'nullable', 'non_required', '#')

gp.MakeFeatureLayer(out_fc, 'fields_lyr')

gp.AddJoin('fields_lyr', 'field_kid', 'Database Connections/plss.sde/plss.field_stats', 'field_kid', 'keep_common')

print 'Calculating fields...'
gp.CalculateField('fields_lyr', 'field_name', '[plss.field_stats.field_name]')
gp.CalculateField('fields_lyr', 'status', '[plss.field_stats.status]')
gp.CalculateField('fields_lyr', 'field_type', '[plss.field_stats.type_of_field]')
gp.CalculateField('fields_lyr', 'prod_gas', '[plss.field_stats.prod_gas]')
gp.CalculateField('fields_lyr', 'prod_oil', '[plss.field_stats.prod_oil]')
gp.CalculateField('fields_lyr', 'activeprod', '[plss.field_stats.activeprod]')
gp.CalculateField('fields_lyr', 'cumm_oil', '[plss.field_stats.cumm_oil]')
gp.CalculateField('fields_lyr', 'maxoilwell', '[plss.field_stats.maxoilwell]')
gp.CalculateField('fields_lyr', 'lastoilpro', '[plss.field_stats.lastoilpro]')
gp.CalculateField('fields_lyr', 'lastoilwel', '[plss.field_stats.lastoilwel]')
gp.CalculateField('fields_lyr', 'lastodate', '[plss.field_stats.lastodate]')
gp.CalculateField('fields_lyr', 'cumm_gas', '[plss.field_stats.cumm_gas]')
gp.CalculateField('fields_lyr', 'maxgaswell', '[plss.field_stats.maxgaswell]')
gp.CalculateField('fields_lyr', 'lastgaspro', '[plss.field_stats.lastgaspro]')
gp.CalculateField('fields_lyr', 'lastgaswel', '[plss.field_stats.lastgaswel]')
gp.CalculateField('fields_lyr', 'lastgdate', '[plss.field_stats.lastgdate]')
gp.CalculateField('fields_lyr', 'avgdepth', '[plss.field_stats.avgdepth]')
gp.CalculateField('fields_lyr', 'avgdepthsl', '[plss.field_stats.avgdepthsl]')
gp.CalculateField('fields_lyr', 'polydate', '[plss.field_stats.polydate]')

gp.RemoveJoin('fields_lyr', 'plss.field_stats')

end_time = strftime('%a, %d %b %Y %H:%M:%S', localtime())
print end_time