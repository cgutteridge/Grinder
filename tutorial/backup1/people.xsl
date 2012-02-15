<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 

    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"

    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:myns="http://example.org/ns/"

    xmlns:g="http://purl.org/openorg/grinder/ns/"
    xmlns:people="http://purl.org/openorg/grinder/ns/people/"
>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>

      <xsl:for-each select="people:row">
        <rdf:Description rdf:about="http://example.com/person/{people:id}">
  
          <foaf:name><xsl:value-of select='people:given-name' /><xsl:text> </xsl:text><xsl:value-of select='people:family-name' /></foaf:name>

          <xsl:if test='people:tel/text()'>
             <foaf:phone rdf:resource='tel:{people:tel}' />
          </xsl:if>
    
          <xsl:for-each select='people:favorite-food'>
             <myns:really-likes-eating>
                <rdf:Description rdf:about='http://example.org/id/likething/{.}'>
                   <rdf:label><xsl:value-of select='.' /></rdf:label>
                </rdf:Description>
             </myns:really-likes-eating>
          </xsl:for-each>

        </rdf:Description>
      </xsl:for-each>

    </rdf:RDF>
  </xsl:template>

</xsl:stylesheet>


