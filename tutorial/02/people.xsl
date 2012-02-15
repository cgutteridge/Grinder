<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 

    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"

    xmlns:g="http://purl.org/openorg/grinder/ns/"
    xmlns:people="http://purl.org/openorg/grinder/ns/people/"
>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>

      <xsl:for-each select="people:row">

        <rdf:Description rdf:about="http://graphite.ecs.soton.ac.uk/example-things/people/{people:id}">
 
        </rdf:Description>

      </xsl:for-each>

    </rdf:RDF>
  </xsl:template>

</xsl:stylesheet>


