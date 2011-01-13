<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://purl.org/openorg/grinder/ns/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:gr="http://purl.org/goodrelations/v1#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:spatialrelations="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"
    xmlns:oo="http://purl.org/openorg/">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:variable name='base-module-uri' select='/g:grinder-data/g:set[@id="base-module-uri"]' />
  <xsl:variable name='base-course-uri' select='/g:grinder-data/g:set[@id="base-course-uri"]' />

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>
      <xsl:comment>TOP</xsl:comment>
      <xsl:apply-templates select="g:row" /> 
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="g:row">
    <!-- 00-69 = 2000-2069, 70-99 = 1970-1999 -->
    <xsl:variable name='y1' select='((number(substring( g:COURSE_NAME, 1, 2 ))+30)mod 100)+1970' />
    <xsl:variable name='y2' select='((number(substring( g:COURSE_NAME, 4, 2 ))+30)mod 100)+1970' />
    <xsl:variable name='module_id' select='substring( g:COURSE_ID, 1, 8 )' />
    <xsl:variable name='course_id' select='substring( g:COURSE_ID, 10, 5 )' />

    (<xsl:value-of select='$y1' />-<xsl:value-of select='$y2' />)
    (<xsl:value-of select='$module_id' />-<xsl:value-of select='$course_id' />)

    <rdf:Description rdf:about="{$base-course-uri}{$course_id}/{$y1}-{$y2}">
    </rdf:Description>
<!--
    <xsl:variable name='uri' select='concat( $base-pos-uri , string(g:Code) )' />
    <rdf:Description rdf:about="{$uri}">
      <rdf:type rdf:resource="http://purl.org/goodrelations/v1#LocationOfSalesOrServiceProvisioning" />
      <xsl:apply-templates />
    </rdf:Description>
    <xsl:for-each select="*">
      <xsl:if test="substring( name(.), 1, 7 ) = 'Offers-'">
        <rdf:Description rdf:about="{$base-offers-uri}{substring( name(.), 8 )}">
          <rdf:type rdf:resource="http://purl.org/goodrelations/v1#Offering" />
          <gr:availableAtOrFrom rdf:resource="{$uri}" />
        </rdf:Description>
      </xsl:if> 
    </xsl:for-each>


  <row>
    <COURSE_ID>XXXX1234-99999-87-88</COURSE_ID>
    <EXTERNAL_COURSE_KEY>XXXX1234-2323-87-88</EXTERNAL_COURSE_KEY>
    <COURSE_NAME>87-88-Demo Course-2323</COURSE_NAME>
  </row>

-->
  </xsl:template>

  <xsl:template match="g:Name">
    <rdfs:label><xsl:value-of select="string(.)"/></rdfs:label>
  </xsl:template>
  
  <xsl:template match="g:Building">
    <spatialrelations:within rdf:resource='{$base-building-uri}{string(.)}' />
  </xsl:template>

  <xsl:template match="g:Mon"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Monday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:Tue"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Tuesday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:Wed"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Wednesday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:Thu"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Thursday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:Fri"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Friday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:Sat"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Saturday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:Sun"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Sunday</xsl:with-param>
  </xsl:call-template></xsl:template> 

  <xsl:template name="open-hours-spec">
    <xsl:param name="day"/>
    <gr:hasOpeningHoursSpecification>
      <rdf:Description rdf:about="{$base-pos-uri}{string(../g:Code)}#{$day}-{string(.)}-{$valid-from}">
        <rdf:type rdf:resource="http://purl.org/goodrelations/v1#OpeningHoursSpecification" />
        <gr:opens rdf:datatype="http://www.w3.org/2001/XMLSchema#time">
          <xsl:value-of select="concat( substring(string(.),1,2), ':', substring(string(.),3,2), ':00' )"/>
        </gr:opens>
        <gr:closes rdf:datatype="http://www.w3.org/2001/XMLSchema#time">
          <xsl:value-of select="concat( substring(string(.),6,2), ':', substring(string(.),8,2), ':00' )"/>
        </gr:closes>
        <gr:hasOpeningHoursDayOfWeek rdf:resource="http://purl.org/goodrelations/v1#{$day}" />
        <gr:validFrom rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
          <xsl:value-of select="concat( $valid-from, 'T00:00:00', $timezone )" />
        </gr:validFrom>
        <gr:validThrough rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
          <xsl:value-of select="concat( $valid-through, 'T23:59:59', $timezone )" />
        </gr:validThrough>
      </rdf:Description>
    </gr:hasOpeningHoursSpecification>
  </xsl:template>

  <xsl:template match="*" priority="-1">
     <!--<xsl:value-of select="concat( name(.), ':', string(.) )" />-->
  </xsl:template>

</xsl:stylesheet>
