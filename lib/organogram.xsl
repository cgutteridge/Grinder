<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 
    xmlns:org="http://www.w3.org/ns/org#"
    xmlns:aiiso="http://purl.org/vocab/aiiso/schema#"
    xmlns:xtypes="http://purl.org/xtypes/"

    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://purl.org/openorg/grinder/ns/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:oo="http://purl.org/openorg/">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:variable name='base-part-uri' select='/g:grinder-data/g:set[@id="base-part-uri"]' />

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>
      <xsl:comment>TOP</xsl:comment>
      <xsl:apply-templates select="g:row" /> 
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="g:row">
    <rdf:Description rdf:about="{$base-part-uri}{g:id}">
      <xsl:apply-templates />
    </rdf:Description>
    <xsl:apply-templates select="g:parent" />
<!--
    <xsl:variable name='uri' select='concat( $base-pos-uri , string(g:Code) )' />
    <rdf:Description rdf:about="{$uri}">
      <rdf:type rdf:resource="http://purl.org/goodrelations/v1#LocationOfSalesOrServiceProvisioning" />
    </rdf:Description>



-->
  </xsl:template>

  <xsl:template match="g:parent">
    <rdf:Description rdf:about="{$base-part-uri}{.}">
      <org:hasSubOrganization rdf:resource="{$base-part-uri}{../g:id}" />
    </rdf:Description>
  </xsl:template>

  <xsl:template match="g:name">
    <rdfs:label><xsl:value-of select="string(.)"/></rdfs:label>
  </xsl:template>
  
  <xsl:template match="*" priority="-1">
     <!--<xsl:value-of select="concat( name(.), ':', string(.) )" />-->
  </xsl:template>

</xsl:stylesheet>
