<cfsetting requestTimeOut = "3600" showDebugOutput = "yes">

<cfset textFiles = "changed_fields,field_list,errors">

<cfquery name="qSelectViews" datasource="plss">
	select view_name
    from user_views
    where view_name like 'FLD%'
</cfquery>

<cfloop query="qSelectViews">
	<cfquery name="qDropViews" datasource="plss">
    	drop view #view_name#
    </cfquery>
</cfloop>

<cfquery name="qExistsFieldStats" datasource="plss">
	select count(*) as count
    from user_tables
    where table_name = 'FIELD_STATS'
</cfquery>
<cfif qExistsFieldStats.count gt 0>
    <cfquery name="qDropFieldStats" datasource="plss">
        drop table field_stats
    </cfquery>
</cfif>

<cfquery name="qExistsFldNames" datasource="plss">
	select count(*) as count
    from user_tables
    where table_name = 'FLD_NAMES'
</cfquery>
<cfif qExistsFldNames.count gt 0>
    <cfquery name="qDropFldNames" datasource="plss">
        drop table fld_names
    </cfquery>
</cfif>

<cfquery name="qExistsFieldsChanged" datasource="plss">
	select count(*) as count
    from user_tables
    where table_name = 'FIELDS_CHANGED'
</cfquery>
<cfif qExistsFieldsChanged.count gt 0>
    <cfquery name="qDropFieldChanged" datasource="plss">
        drop table fields_changed
    </cfquery>
</cfif>

<cfloop index="i" list="#textFiles#">
	<cfoutput>
	<cfif FileExists("e:/field_boundaries/#i#.txt")>
		<cffile action="delete" file="e:/field_boundaries/#i#.txt">
    </cfif>
    </cfoutput>
</cfloop>
