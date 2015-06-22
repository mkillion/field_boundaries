<!---<cfif cgi.REMOTE_ADDR neq '127.0.0.1'>
    Access denied.<br>
    <cfabort>
	</cfif>--->

<cfsetting requestTimeOut = "3600" showDebugOutput = "yes">

<!--- Set where clause used to create field views and list of fields to be processed. Select one of the following and comment out the others. --->

<!--- use this when doing a complete replacement (batch runs) or to create views for all fields: --->
<!---<cfset whereClause = "">--->

<!--- use this when running partial updates: --->
<cfset whereClause = "kid in (select kid from fields_changed)">

<!--- use this to process only selected fields: --->
<!---<cfset whereClause = "kid = 1000151739">--->

<!--- use this for testing purposes, to run a small sample only: --->
<!---<cfset whereClause = "lower(field_name) like 'q%'">--->


<!--- ########## CREATE FIELD VIEWS SECTION ########## --->

<!--- Get field names: --->
<cfquery name="qQueryFields" datasource="plss">
    select kid, field_name, 'FLD_' ||
         replace(replace(replace(replace(replace(replace(substr(field_name,1,10),' ','_'),'-',''),'&',''),'.','_'),chr(39),''),chr(34),'')
         || '_' || kid as data_name, status, produces_oil, produces_gas
    from nomenclature.fields
    <cfif whereClause neq "">
    	where #PreserveSingleQuotes(whereClause)#
	</cfif>
   	order by data_name
</cfquery>

<!--- Create field_stats table with 1 line from each view (excludes plss_recnmbr field): --->
<cfquery name="qCreateFieldStats" datasource="plss">
	create table field_stats
    	(
        field_kid varchar2(25),
        field_name varchar2(50),
        status varchar2(25),
        type_of_field varchar2(5),
        prod_gas varchar2(5),
        prod_oil varchar2(5),
        lastgdate varchar2(50),
        lastodate varchar2(50),
        cumm_oil number,
        lastoilpro number,
        maxoilwell number,
        lastoilwel number,
        cumm_gas number,
        lastgaspro number,
        maxgaswell number,
        lastgaswel number,
    	avgdepth number,
        avgdepthsl number,
        polydate varchar2(100),
        activeprod varchar2(7)
        )
</cfquery>

<cfloop query="qQueryFields">
	<cfoutput>
	<!--- Create a view for each field from nomenclature.fields, nomenclature.fields_plss_10_acres, nomenclature.fields_production, field_top_summary, field_top_summary_sealevel tables: --->
  	<cfquery name="qBuildViews" datasource="plss">
		create or replace view #data_name# as (
		select c.field_kid FIELD_KID, c.plss_recnmbr PLSS_RECNMBR, a.Field_name FIELD_NAME,
		   a.produces_gas PRODUCES_GAS, a.produces_oil PRODUCES_OIL, a.status STATUS, a.type_of_field TYPE_OF_FIELD,
		   to_char(sysdate, 'YYYY-MM-DD  HH:MI:SS') POLYDATE,
		   round(oil_stats.cumm_pro) CUMMULATIVE_OIL,
           curr_oil.production LAST_OIL_PRODUCTION,
		   oil_stats.max_wellcount MAX_OIL_WELLS,
           curr_oil.wells LAST_OIL_WELLS,
		   round(gas_stats.cumm_pro) CUMMULATIVE_GAS,
           curr_gas.production LAST_GAS_PRODUCTION,
		   gas_stats.max_wellcount MAX_GAS_WELLS,
           curr_gas.wells LAST_GAS_WELLS,
		   fts.avg_depth_top AVG_DEPTH,
		   fts_sea.avg_depth_top AVG_DEPTH_SEALEVEL,
           curr_oil.lastodate LASTODATE,
           curr_gas.lastgdate LASTGDATE
		from nomenclature.fields a, nomenclature.fields_plss_10_acres c,
			 (select field_kid, sum(production) + (select cum_thru_1965 from nomenclature.fields where kid = #kid#) CUMM_PRO, max(wells) MAX_WELLCOUNT, avg(wells) AVG_WELLCOUNT
			   from nomenclature.fields_production
			  where field_kid = #kid#
				and product = 'O'
				and year > 1965
			  group by field_kid) OIL_STATS,

              (select month||'-'||year as lastodate, wells, production, field_kid
				from nomenclature.fields_production
				where month = (select max(month) from nomenclature.fields_production where year = (select max(year) from nomenclature.fields_production where field_kid = #kid# AND product = 'O') and field_kid = #kid# AND product = 'O')
  				and year = (select max(year) from nomenclature.fields_production where field_kid = #kid# AND product = 'O')
  				and field_kid = #kid#
  				and product = 'O') CURR_OIL,

              (select month||'-'||year as lastgdate, wells, production, field_kid
				from nomenclature.fields_production
				where month = (select max(month) from nomenclature.fields_production where year = (select max(year) from nomenclature.fields_production where field_kid = #kid# AND product = 'G') and field_kid = #kid# AND product = 'G')
  				and year = (select max(year) from nomenclature.fields_production where field_kid = #kid# AND product = 'G')
  				and field_kid = #kid#
  				and product = 'G') CURR_GAS,

			 (select field_kid, sum(production) CUMM_PRO, max(wells) MAX_WELLCOUNT, avg(wells) AVG_WELLCOUNT
			   from nomenclature.fields_production
			  where field_kid = #kid#
				and product = 'G'
			  group by field_kid) GAS_STATS,

			 (select field_kid, avg(avg_depth_top) AVG_DEPTH_TOP
				from field_top_summary
			   where field_kid = #kid#
				 and avg_depth_top is not null
			   group by field_kid
			 ) FTS,

			 (select field_kid, 0 - avg(avg_depth_top) AVG_DEPTH_TOP
				from field_top_summary_sealevel
			   where field_kid = #kid#
				 and avg_depth_top is not null
			   group by field_kid
			 ) FTS_SEA

	   	where a.kid = #kid#
			and a.kid = oil_stats.field_kid (+)
		 	and a.kid = gas_stats.field_kid (+)
		 	and a.kid = c.field_kid
		 	and a.kid = fts.field_kid (+)
		 	and a.kid = fts_sea.field_kid (+)
            and a.kid = curr_oil.field_kid (+)
            and a.kid = curr_gas.field_kid (+)
		 )
	</cfquery>

    <!--- Populate field_stats table: --->
    <cfquery name="qFieldStats" datasource="plss">
   		insert into field_stats (select distinct field_kid, field_name, status, type_of_field, produces_gas, produces_oil, lastgdate, lastodate, cummulative_oil, last_oil_production, max_oil_wells, last_oil_wells,
        	cummulative_gas, last_gas_production, max_gas_wells, last_gas_wells, avg_depth, avg_depth_sealevel, polydate,
            <cfif UCase(#status#) eq "ACTIVE">
            	<cfif UCase(#produces_gas#) eq "YES">
                	<cfif UCase(#produces_oil#) eq "YES">
                    	'OILGAS'
                    <cfelse>
                    	'GAS'
                    </cfif>
                <cfelse>
                	<cfif UCase(#produces_oil#) eq "YES">
                    	'OIL'
                     <cfelse>
                   		''
                    </cfif>
                </cfif>
            <cfelse>
            	''
            </cfif>
			from #data_name#)
    </cfquery>
	</cfoutput>
</cfloop>

<!--- ########## CREATE FIELD LIST SECTION ########## --->

<!--- Set field list file name: --->
<cfset field_list = "e:/field_boundaries/field_list.txt">

<!--- Delete previous field list if present: --->
<cfif FileExists(field_list)>
	<cffile action="delete" file="#field_list#">
</cfif>

<!--- Initialize field list: --->
<cffile action="write" file="#field_list#" output="" addnewline="no">

<!--- Create a table of field names selectable by row number (comment out query after 1st run): --->
<cfquery name="qCreateFld_Names" datasource="plss">
	create table fld_names as
   	(select a.*, rownum as rownumber from
   	(select kid, field_name, 'FLD_' ||
         replace(replace(replace(replace(replace(replace(substr(field_name,1,10),' ','_'),'-',''),'&',''),'.','_'),chr(39),''),chr(34),'')
         || '_' || kid as data_name
    from nomenclature.fields
    <cfif whereClause neq "">
    	where #PreserveSingleQuotes(whereClause)#
    </cfif>
   	order by data_name) a
    )
</cfquery>

<!--- Query fld_names table (edit rownumber ranges to run in batches): --->
<cfquery name="qFields" datasource="plss">
	select * from fld_names
    where rownumber > 0
</cfquery>

<cfloop query="qFields">
	<cfoutput>
    <!--- write field name to field list: --->
    <cffile action="append" file="#field_list#" output="#data_name#" addnewline="yes">
	</cfoutput>
</cfloop>