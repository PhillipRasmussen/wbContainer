
<!--- @@displayname: Webolution Container installation manifest --->
<!--- @@Description: Installation manifest for the Webolution Container plugin --->
<cfcomponent extends="farcry.core.webtop.install.manifest" name="manifest">

<cfset this.name = "Webolution Container v1.0" />
<cfset this.description = "Webolution Creator" />
<cfset this.lRequiredPlugins = "" />
<cfset this.version = "1.0" />
<cfset addSupportedCore(majorVersion="7", minorVersion="0", patchVersion="0") />

</cfcomponent>