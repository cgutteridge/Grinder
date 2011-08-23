<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 

    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:spacerel="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"
    xmlns:oo="http://purl.org/openorg/"

    xmlns:g="http://purl.org/openorg/grinder/ns/"
    xmlns:b="http://purl.org/openorg/grinder/ns/buildings/"
    xmlns:s="http://purl.org/openorg/grinder/ns/sites/"
    xmlns:r="http://purl.org/openorg/grinder/ns/rooms/"
>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:variable name='base-site-uri' select='/g:grinder-data/g:set[@name="base-site-uri"]' />
  <xsl:variable name='site-code-scheme' select='/g:grinder-data/g:set[@name="site-code-scheme"]' />

  <xsl:variable name='base-building-uri' select='/g:grinder-data/g:set[@name="base-building-uri"]' />
  <xsl:variable name='building-code-scheme' select='/g:grinder-data/g:set[@name="building-code-scheme"]' />

  <xsl:variable name='base-room-uri' select='/g:grinder-data/g:set[@name="base-room-uri"]' />
  <xsl:variable name='room-code-scheme' select='/g:grinder-data/g:set[@name="room-code-scheme"]' />

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>
      <xsl:comment>TOP</xsl:comment>
      <xsl:apply-templates select="*" /> 
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="s:row">
    <rdf:Description rdf:about="{$base-site-uri}{s:id}">
      <rdf:type rdf:resource="http://www.w3.org/ns/org#Site" />
      <xsl:apply-templates />
    </rdf:Description>
  </xsl:template>
  <xsl:template match="b:row">
    <rdf:Description rdf:about="{$base-building-uri}{b:id}">
      <rdf:type rdf:resource="http://vocab.deri.ie/rooms#Building" />
      <xsl:apply-templates />
    </rdf:Description>
  </xsl:template>
  <xsl:template match="r:row">
    <rdf:Description rdf:about="{$base-room-uri}{r:id}">
      <rdf:type rdf:resource="http://vocab.deri.ie/rooms#Room" />
      <xsl:apply-templates />
    </rdf:Description>
  </xsl:template>

  <xsl:template match="s:id">
    <xsl:if test="string(.) != ''">
      <skos:notation rdf:datatype="{$site-code-scheme}"><xsl:value-of select="string(.)" /></skos:notation>
    </xsl:if>
  </xsl:template>
  <xsl:template match="b:id">
    <xsl:if test="string(.) != ''">
      <skos:notation rdf:datatype="{$building-code-scheme}"><xsl:value-of select="string(.)" /></skos:notation>
    </xsl:if>
  </xsl:template>
  <xsl:template match="r:id">
    <xsl:if test="string(.) != ''">
      <skos:notation rdf:datatype="{$room-code-scheme}"><xsl:value-of select="string(.)" /></skos:notation>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:name|s:name|b:name|r:name">
    <xsl:if test="string(.) != ''">
    <rdfs:label><xsl:value-of select="string(.)"/></rdfs:label>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:lat|s:lat|b:lat|r:lat">
    <xsl:if test="string(.) != ''">
    <geo:lat><xsl:value-of select="string(.)"/></geo:lat>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:long|s:long|b:long|r:long">
    <xsl:if test="string(.) != ''">
    <geo:long><xsl:value-of select="string(.)"/></geo:long>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:access|s:access|b:access|r:access">
    <xsl:if test="string(.) != ''">
    <oo:access><xsl:value-of select="string(.)"/></oo:access>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:page|s:page|b:page|r:page">
    <xsl:if test="string(.) != ''">
    <foaf:page rdf:resource="{string(.)}" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:depiction|s:depiction|b:depiction|r:depiction">
    <xsl:if test="string(.) != ''">
    <foaf:depiction rdf:resource="{string(.)}" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="g:site|s:site|b:site|r:site">
    <xsl:if test="string(.) != ''">
    <spacerel:within rdf:resource="{$base-site-uri}{string(.)}" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="g:building|s:building|b:building|r:building">
    <xsl:if test="string(.) != ''">
    <spacerel:within rdf:resource="{$base-building-uri}{string(.)}" />
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

sites, rooms, other?
-->
