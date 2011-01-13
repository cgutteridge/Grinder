<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 

    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://purl.org/openorg/grinder/ns/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:dcat="http://www.w3.org/ns/dcat#"
    xmlns:void="http://www.w3.org/ns/dcat#"
    xmlns:oo="http://purl.org/openorg/">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>
      <xsl:comment>TOP</xsl:comment>
      <xsl:apply-templates select="g:row" /> 
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="g:row">
    <rdf:Description>
      <xsl:choose>
        <xsl:when test="g:self-assigned-uri/text()">
           <xsl:attribute name="rdf:about"><xsl:value-of select="g:self-assigned-uri" /></xsl:attribute>
           <xsl:if test="g:government-assigned-uri/text()">
             <owl:sameAs rdf:resource="{g:government-assigned-uri}" />
           </xsl:if>
        </xsl:when>
        <xsl:when test="g:government-assigned-uri/text()">
           <xsl:attribute name="rdf:about"><xsl:value-of select="g:government-assigned-uri" /></xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <rdf:type rdf:resource="http://www.w3.org/ns/org#FormalOrganization" />
      <rdf:type rdf:resource="http://purl.org/vocab/aiiso/schema#Institution" />
      <xsl:if test="g:name/text()">
        <rdfs:label><xsl:value-of select="g:name"/></rdfs:label>
      </xsl:if>
      <xsl:if test="g:homepage/text()">
        <foaf:homepage rdf:resource="{g:homepage}" />
      </xsl:if>
      <oo:open-data-catalog>
        <dcat:Catalog>
          <xsl:if test="g:data-catalog-uri/text()">
             <xsl:attribute name="rdf:about"><xsl:value-of select="g:data-catalog-uri" /></xsl:attribute>
          </xsl:if>
          <xsl:if test="g:data-homepage/text()">
             <foaf:homepage rdf:resource='{g:data-homepage}' />
          </xsl:if>
          <rdfs:comment>Contact <xsl:value-of select="g:contact-name" /> <xsl:value-of select="g:contact-email" /></rdfs:comment>

        </dcat:Catalog>
      </oo:open-data-catalog>
      <xsl:if test="g:institution-sparql/text()">
        <oo:sparql rdf:resource="{g:institution-sparql}" />
      </xsl:if>
    </rdf:Description>
  </xsl:template>

</xsl:stylesheet>
