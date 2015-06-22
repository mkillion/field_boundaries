<cfsetting requestTimeOut = "3600" showDebugOutput = "yes">

<!--- Change name of fields layer in the following 3 queries to match current (lambert) layer name: --->
<cfquery name="qChangedFields" datasource="plss">
	select a.field_kid as field_kid, a.field_name as field_name
    from oilgas_fields_lam a, nomenclature.fields b
    where a.polydate < b.update_date
    and a.field_kid = b.kid
</cfquery>

<cfquery name="qDeletedFields" datasource="plss">
	select field_kid
    from oilgas_fields_lam
    where field_kid not in (select kid from nomenclature.fields)
</cfquery>

<cfquery name="qNewFields" datasource="plss">
	select kid from nomenclature.fields
    where kid not in (select field_kid from oilgas_fields_lam) and kid <> 0
</cfquery>

<!--- Set changed fields list file name: --->
<cfset changed_fields = "e:/field_boundaries/changed_fields.txt">

<!--- Delete previous list if present: --->
<cfif FileExists(changed_fields)>
	<cffile action="delete" file="#changed_fields#">
</cfif>

<!--- Initialize list: --->
<cffile action="write" file="#changed_fields#" output="" addnewline="no">

<!--- Create table to hold KIDs of changed fields: --->
<cfquery name="qCreateTable" datasource="plss">
	create table fields_changed(kid number)
</cfquery>

<cfloop query="qChangedFields">
	<cfoutput>
		<!--- write field kid to text file (used by delete fields script): --->
        <cffile action="append" file="#changed_fields#" output="#field_kid#" addnewline="yes">

        <!--- write field kid to table (used by create field views template): --->
        <cfquery name="qInsertKID" datasource="plss">
            insert into fields_changed values(#field_kid#)
        </cfquery>
	</cfoutput>
</cfloop>

<cfloop query="qDeletedFields">
	<cfoutput>
    	<!--- Append KIDs of deleted fields to changed_fields list: --->
    	<cffile action="append" file="#changed_fields#" output="#field_kid#" addnewline="yes">
    </cfoutput>
</cfloop>

<cfloop query="qNewFields">
	<cfoutput>
    	<!--- Append KIDs of new fields to changed_fields list: --->
        <cffile action="append" file="#changed_fields#" output="#kid#" addnewline="yes">

        <cfquery name="qInsertNewKID" datasource="plss">
        	insert into fields_changed values(#kid#)
        </cfquery>
    </cfoutput>
</cfloop>
