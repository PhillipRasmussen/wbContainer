<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/rules/container.cfc,v 1.41.2.1 2006/01/04 07:50:02 paul Exp $
$Author: paul $
$Date: 2006/01/04 07:50:02 $
$Name: milestone_3-0-1 $
$Revision: 1.41.2.1 $

|| DESCRIPTION || 
$Description: Core container management component. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent extends="farcry.core.packages.rules.container" displayname="Container Management" hint="Manages all core functions for container instance management." bObjectBroker="true" fuAlias="container" bRefObjects="false" icon="fa-wrench">
	
	
	
	<cffunction name="populate" access="public" hint="Gets Rule instances and execute them">
		<cfargument name="aRules" type="array" required="true">
		<cfargument name="originalID" type="string" required="false" default="">
		
		<cfset var i=1>
		<cfset var o="">
		<cfset var rule="">
		<cfset var ruleHTML="" />
		<cfset var aProps = arraynew(1) />
		<cfset var stProps = structnew() />
		<cfset var prop = "" />
		<cfset var ruleError = "" />
		
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
	
		
		<cfset request.aInvocations = arrayNew(1)>
		<cfset request.aRuleIDs = []>

		<cfloop from="1" to="#arrayLen(arguments.aRules)#" index="i">
			 <cftry> 
			
				<cfif request.mode.design and request.mode.showcontainers gt 0>
					<!--- request.thiscontainer is set up in the container tag and corresponds to the page container, not the shared container --->
					<skin:view objectid="#arguments.aRules[i]#" webskin="displayAdminToolbar" index="#i#" r_html="ruleHTML" arraylen="#arraylen(arguments.aRules)#" originalID="#arguments.originalID#" />
					
					<cfset arrayappend(request.aInvocations, ruleHTML) />
					<cfset arrayappend(request.aRuleIDs, #arguments.aRules[i]#) />
				</cfif>
				
				<!--- Detaermin the type of rule --->
				<cfset rule = application.fapi.findType(arguments.aRules[i]) />
				
				<cfif len(rule)>
					<cfif application.fapi.hasWebskin(rule,"execute")>
						<skin:view objectid="#arguments.aRules[i]#" typename="#rule#" webskin="execute" r_html="ruleHTML" />
					<cfelse>
						<cfsavecontent variable="ruleHTML">
							<cfoutput>#application.fapi.getContentType(rule).execute(objectid=arguments.aRules[i])#</cfoutput>
						</cfsavecontent>
					</cfif>
					
					<cfset arrayappend(request.aInvocations, ruleHTML) />
					<cfset arrayappend(request.aRuleIDs, #arguments.aRules[i]#) />
				<cfelse>
					<cfif isdefined("url.debug") and url.debug EQ 1>
						<skin:bubble title="Error with rule" message="Could not resolve rule type for rule #i# on container #arguments.originalID#" />
					</cfif>
				</cfif>
							
			  	<cfcatch type="any">
					
					<!--- <cfset oError.logData(oError.normalizeError(cfcatch)) /> --->
					
					<!--- show error if debugging --->
					<cfif isdefined("request.mode.debug") and request.mode.debug EQ 1>
						<cfset request.cfdumpinited = false>
						
						<skin:bubble title="Error with rule '#application.stcoapi[rule].displayName#'" bAutoHide="false" tags="rule,error">
							<cfoutput>#cfcatch.message#<br />#cfcatch.detail#</cfoutput>
						</skin:bubble>							
						
						<cfsavecontent variable="ruleError">
							<cfdump var="#cfcatch#" expand="false" label="#cfcatch.message#">
						</cfsavecontent>
						<cfset arrayappend(request.aInvocations, "#ruleError#") />
						
				  	<cfelseif request.mode.design and request.mode.showcontainers gt 0>
						<skin:bubble title="Error with rule '#rule#'" bAutoHide="true" tags="rule,error">
							<cfoutput>#cfcatch.message#<br />#cfcatch.detail#</cfoutput>
						</skin:bubble>
					</cfif>
					<!--- Output a HTML Comment for debugging purposes --->
					<cfoutput>
						<!-- container failed on ruleID: #arguments.aRules[i]# (#rule#) 
						<br> 
						#cfcatch.Detail#<br>#cfcatch.Message#
					 	-->
					 </cfoutput>
				</cfcatch>
			</cftry> 
		</cfloop>
		<cfif request.mode.design and request.mode.showcontainers gt 0>
		<cfoutput><div class="containerContent"  data-objectid="#arguments.originalID#"></cfoutput>
		</cfif>
		<cfloop from="1" to="#arrayLen(request.aInvocations)#" index="i">
			
			<cfif isStruct(request.aInvocations[i])>
				<cfif structKeyExists(request.aInvocations[i],"preHTML")>
					<cfoutput>#request.aInvocations[i].preHTML#</cfoutput>
				</cfif>

				<skin:view objectid="#request.aInvocations[i].objectID#" typename="#request.aInvocations[i].typename#" webskin="#request.aInvocations[i].method#" alternateHTML="[#request.aInvocations[i].method#] does not exist" />

				<cfif structKeyExists(request.aInvocations[i],"postHTML")>
					<cfoutput>#request.aInvocations[i].postHTML#</cfoutput>
				</cfif>
			<cfelse>
				<cfif request.mode.design and request.mode.showcontainers gt 0 AND request.aInvocations[i].find('ruleadmin')>
				<cfoutput><div class="ruleContent" data-objectid="#request.aRuleIDs[i]#"></cfoutput>
				<cfelseif request.mode.design and request.mode.showcontainers gt 0>
					<cfoutput><div class="ruleContentDetails"></cfoutput>
				</cfif>
				<cfoutput>#request.aInvocations[i]#</cfoutput>
				<cfif request.mode.design and request.mode.showcontainers gt 0 AND NOT request.aInvocations[i].find('ruleadmin')>
				<cfoutput></div></div></cfoutput>				
				</cfif>
			</cfif>
			
		</cfloop>
		<cfif request.mode.design and request.mode.showcontainers gt 0>
		<cfoutput></div></cfoutput>
		</cfif>
	</cffunction>
	
	

	
</cfcomponent>
