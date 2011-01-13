<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 
  xml:base="http://programme.ecs.soton.ac.uk/examples/dev8d.rdf" 
  xmlns='http://purl.org/prog/'
  xmlns:event='http://purl.org/NET/c4dm/event.owl#'
  xmlns:dcterms='http://purl.org/dc/terms/'
  xmlns:foaf='http://xmlns.com/foaf/0.1/'
  xmlns:geo='http://www.w3.org/2003/01/geo/wgs84_pos#'
  xmlns:g="http://purl.org/openorg/grinder/ns/"
  xmlns:g1="http://purl.org/openorg/grinder/ns/1/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tl='http://purl.org/NET/c4dm/timeline.owl#'
  xmlns:spacerel="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"
>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:variable name='base-uri' select='/g:grinder-data/g:set[@id="base-uri"]' />
  <xsl:variable name='event-start' select='/g:grinder-data/g:set[@id="event-start"]' />
  <xsl:variable name='event-end' select='/g:grinder-data/g:set[@id="event-end"]' />

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>
      <xsl:comment>TOP</xsl:comment>
      <rdf:Description rdf:about=''>
        <foaf:primaryTopic rdf:resource='{$base-uri}#event' />
      </rdf:Description>

      <event:Event rdf:about="#event">
        <event:place rdf:resource="#loc-conference_venue"/>
        <foaf:based_near rdf:resource="http://dbpedia.org/resource/London"/>
        <foaf:homepage rdf:resource="http://www.dev8d.org/"/>
        <rdfs:label>JISC Dev8D 2010</rdfs:label>
        <xsl:if test="string($event-start) != '' and string($event-end) !=''">
          <event:time>
            <tl:Interval>
              <tl:start datatype="http://www.w3.org/2001/XMLSchema#dateTime">2010-02-24T10:30:00</tl:start>
              <tl:end datatype="http://www.w3.org/2001/XMLSchema#dateTime">2010-02-27T16:30:00</tl:end>
            </tl:Interval>
          </event:time>
        </xsl:if>
      </event:Event>

      <xsl:apply-templates select="g:row" /> 
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="g:row">
    <rdf:Description rdf:about="{$base-uri}event-{g:id}">
      <xsl:apply-templates />
    </rdf:Description>
  </xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

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
     <xsl:comment><xsl:value-of select="concat( name(.), ': ', string(.) )" /></xsl:comment>
  </xsl:template>

</xsl:stylesheet>
