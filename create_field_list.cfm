<cfif cgi.REMOTE_ADDR neq '127.0.0.1'>
    Access denied.
    <cfabort>
</cfif>

<cfsetting requestTimeOut = "3600" showDebugOutput = "yes">

<!--- Set field list file name: --->
<cfset field_list = "d:/projects/field_boundaries/field_list.txt">

<!--- Delete previous field list if present: --->
<cfif FileExists(field_list)>
	<cffile action="delete" file="#field_list#">
</cfif>

<!--- Initialize field list: --->
<cffile action="write" file="#field_list#" output="" addnewline="no">

<!--- Create a table of field names selectable by row number (comment out query after 1st run): --->
<cfquery name="qQueryFields" datasource="plss">
	create table fld_names as (
   	select a.*, rownum as rownumber from
   	(select kid, field_name, 'FLD_' ||
         replace(replace(replace(replace(replace(replace(substr(field_name,1,10),' ','_'),'-',''),'&',''),'.','_'),chr(39),''),chr(34),'')
         || '_' || kid as data_name
    from nomenclature.fields
    where kid <> 0
    <!---where lower(field_name) like 'q%'--->
    <!---where kid in (select kid from fields_changed)---> 
   	order by data_name) a
    )
</cfquery>

<!--- Query fld_names table (edit rownumber ranges to run in batches): --->
<cfquery name="qFields" datasource="plss">
	select * from fld_names
    where rownumber > 6000 and rownumber <= 7000
</cfquery>

<cfloop query="qFields">
	<cfoutput>
    
    <!--- write field name to field list: --->
    <cffile action="append" file="#field_list#"
    	output="#data_name#"
        addnewline="yes">
       
	</cfoutput>
</cfloop>