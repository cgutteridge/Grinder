<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://purl.org/openorg/grinder/ns/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:spatialrelations="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"
    xmlns:oo="http://purl.org/openorg/"
    xmlns:ns="http://id.southampton.ac.uk/ns/"
>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:variable name='base-building-uri' select='/g:grinder-data/g:set[@id="base-building-uri"]' />
  <xsl:variable name='base-room-uri' select='/g:grinder-data/g:set[@id="base-room-uri"]' />

  <xsl:variable name='base-seating-uri' select='/g:grinder-data/g:set[@id="base-seating-uri"]' />
  <xsl:variable name='base-feature-uri' select='/g:grinder-data/g:set[@id="base-features-uri"]' />

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>
      <xsl:comment>TOP</xsl:comment>
      <xsl:apply-templates select="g:row" /> 
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="g:row">
    <xsl:variable name='uri' select='concat( $base-room-uri , string(g:building), "-", string(g:room) )' />
    <rdf:Description rdf:about="{$uri}">
      <rdf:type rdf:resource="http://vocab.deri.ie/rooms#Room" />
      <xsl:apply-templates />
    </rdf:Description>
  </xsl:template>

  <xsl:template match="g:name">
    <rdfs:label><xsl:value-of select="string(.)"/></rdfs:label>
  </xsl:template>
  
  <xsl:template match="g:building">
    <spatialrelations:within rdf:resource='{$base-building-uri}{string(.)}' />
  </xsl:template>

  <xsl:template match="g:access"><ns:access><xsl:value-of select="string(.)"/></ns:access></xsl:template>
  <xsl:template match="g:seated-capacity"><ns:seated-capacity><xsl:value-of select="string(.)"/></ns:seated-capacity></xsl:template>
  <xsl:template match="g:access"><ns:access><xsl:value-of select="string(.)"/></ns:access></xsl:template>
  <xsl:template match="g:booking-term"><ns:booking-term><xsl:value-of select="string(.)"/></ns:booking-term></xsl:template>
  <xsl:template match="g:booking-not-term"><ns:booking-not-term><xsl:value-of select="string(.)"/></ns:booking-not-term></xsl:template>

  <xsl:template match="g:presenter-wheelchair"><xsl:call-template name="boolean"/></xsl:template>
  <xsl:template match="g:audience-wheelchair"><xsl:call-template name="boolean"/></xsl:template>
  <xsl:template match="g:access-stairs"><xsl:call-template name="boolean"/></xsl:template>
  <xsl:template match="g:access-lift"><xsl:call-template name="boolean"/></xsl:template>

  <xsl:template match="g:pics">
    <foaf:depiction rdf:resource='{string(.)}' />
  </xsl:template>
  <xsl:template match="g:seating">
    <ns:seating rdf:resource='{$base-seating-uri}{string(.)}' />
  </xsl:template>
  <xsl:template match="g:facilities">
    <ns:facility rdf:resource='{$base-feature-uri}{string(.)}' />
  </xsl:template>

  <xsl:template match="*" priority="-1">
     <!--<xsl:value-of select="concat( name(.), ':', string(.) )" />-->
  </xsl:template>

  <xsl:template name="boolean">
    <xsl:element name="ns:{name(.)}" use-attribute-sets='title-style'>
      <xsl:choose>
        <xsl:when test='string(.)="yes"'>true</xsl:when>
        <xsl:when test='string(.)="y"'>true</xsl:when>
        <xsl:when test='string(.)="YES"'>true</xsl:when>
        <xsl:when test='string(.)="Y"'>true</xsl:when>
        <xsl:when test='string(.)="true"'>true</xsl:when>
        <xsl:when test='string(.)="1"'>true</xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
    
  <xsl:attribute-set name="title-style">
    <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#boolean</xsl:attribute>
  </xsl:attribute-set>

</xsl:stylesheet>
