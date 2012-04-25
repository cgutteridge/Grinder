<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 

    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"

    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:dcat="http://www.w3.org/ns/dcat#"
    xmlns:void="http://www.w3.org/ns/dcat#"
    xmlns:oo="http://purl.org/openorg/"
    xmlns:local="http://id.southampton.ac.uk/ns/"

    xmlns:g="http://purl.org/openorg/grinder/ns/"
>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>
      <xsl:comment>TOP</xsl:comment>
      <xsl:apply-templates select="g:row" /> 
    </rdf:RDF>
  </xsl:template>
<!--
  <row filename='people.tsv'>
	<given tag='Pat'>Pat</given>
	<family tag='McSweeney'>McSweeney</family>
	<tel></tel>
	<email sha1='0b1ca0d57c8ac41adf565b20295e97c5715d585c'>pat@ecs.soton.ac.uk</email>
	<likes>Cheese</likes>
	<likes>Beer</likes>
	<likes>Toast</likes>
  </row>

-->

  <xsl:template match="g:row">
    <xsl:variable name="uri">http://example.org/id/people/<xsl:value-of select='g:given/@tag' /><xsl:value-of select='g:family/@tag' /></xsl:variable>

    <foaf:Person rdf:about="{$uri}">

      <foaf:name><xsl:value-of select='g:given' /><xsl:text> </xsl:text><xsl:value-of select='g:family' /></foaf:name>

      <xsl:if test='g:tel/text()'>
         <foaf:phone rdf:resource='tel:{g:tel}' />
      </xsl:if>

      <xsl:for-each select='g:likes'>
         <local:likes>
            <rdf:Description rdf:about='http://example.org/id/likething/{.}'>
                <rdf:label><xsl:value-of select='.' /></rdf:label>
            </rdf:Description>
         </local:likes>
      </xsl:for-each>


    </foaf:Person>
  </xsl:template>

</xsl:stylesheet>


