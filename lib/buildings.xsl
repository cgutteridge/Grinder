<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 

    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://purl.org/openorg/grinder/ns/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:spacerel="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"
    xmlns:oo="http://purl.org/openorg/">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:variable name='base-building-uri' select='/g:grinder-data/g:set[@id="base-building-uri"]' />
  <xsl:variable name='base-site-uri' select='/g:grinder-data/g:set[@id="base-site-uri"]' />
  <xsl:variable name='building-number-scheme' select='/g:grinder-data/g:set[@id="building-number-scheme"]' />

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>
      <xsl:comment>TOP</xsl:comment>
      <xsl:apply-templates select="g:row" /> 
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="g:row">
    <rdf:Description rdf:about="{$base-building-uri}{g:id}">
      <xsl:apply-templates />
    </rdf:Description>
  </xsl:template>

  <xsl:template match="g:id">
    <xsl:if test="string(.) != ''">
    <skos:notation rdf:datatype="{$building-number-scheme}"><xsl:value-of select="string(.)" /></skos:notation>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:name">
    <xsl:if test="string(.) != ''">
    <rdfs:label><xsl:value-of select="string(.)"/></rdfs:label>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:lat">
    <xsl:if test="string(.) != ''">
    <geo:lat><xsl:value-of select="string(.)"/></geo:lat>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:long">
    <xsl:if test="string(.) != ''">
    <geo:long><xsl:value-of select="string(.)"/></geo:long>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:page">
    <xsl:if test="string(.) != ''">
    <foaf:page rdf:resource="{string(.)}" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:depiction">
    <xsl:if test="string(.) != ''">
    <foaf:depiction rdf:resource="{string(.)}" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="g:site">
    <xsl:if test="string(.) != ''">
    <spacerel:within rdf:resource="{$base-site-uri}{string(.)}" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*" priority="-1">
     <!--<xsl:value-of select="concat( name(.), ':', string(.) )" />-->
  </xsl:template>

</xsl:stylesheet>
<!--
TODO:
	features:
	architect:
	occupants:NERC, School of Ocean &amp; Earth Sciences, Library, Common Learning Spaces and Public Workstations
	building-date:1995
	architects:
	awards:
-->
