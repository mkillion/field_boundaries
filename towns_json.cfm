    <!--- --->

    <cfset output_path = "D:/Projects/wwc5">
    <cfset file_name = "towns.txt">

	<cfquery name="qTowns" datasource="plss">
		select distinct feature_na from mk_places
		order by feature_na
	</cfquery>

	<cffile action="write" file="#output_path#/#file_name#" output='{identifier: "name",'>
    <cffile action="append" file="#output_path#/#file_name#" output='items: ['>
	<cfloop query="qTowns">
    	<cfif qTowns.currentrow neq qTowns.recordcount>
			<cffile action="append" file="#output_path#/#file_name#" output='{name: "#feature_na#"},'>
        <cfelse>
        	<!--- omit final comma: --->
        	<cffile action="append" file="#output_path#/#file_name#" output='{name: "#feature_na#"}'>
        </cfif>
	</cfloop>
	<cffile action="append" file="#output_path#/#file_name#" output=']}'>
