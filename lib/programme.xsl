<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 
  xml:base="http://programme.ecs.soton.ac.uk/examples/dev8d.rdf" 
  xmlns='http://purl.org/prog/'
  xmlns:event='http://purl.org/NET/c4dm/event.owl#'
  xmlns:prog='http://purl.org/prog/'
  xmlns:dcterms='http://purl.org/dc/terms/'
  xmlns:bio="http://purl.org/vocab/bio/0.1/"
  xmlns:foaf='http://xmlns.com/foaf/0.1/'
  xmlns:geo='http://www.w3.org/2003/01/geo/wgs84_pos#'
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tl='http://purl.org/NET/c4dm/timeline.owl#'
  xmlns:spacerel="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"

  xmlns:g="http://purl.org/openorg/grinder/ns/"
  xmlns:timeslots="http://purl.org/openorg/grinder/ns/timeslots/"
  xmlns:people="http://purl.org/openorg/grinder/ns/people/"
  xmlns:locations="http://purl.org/openorg/grinder/ns/locations/"
  xmlns:sessions="http://purl.org/openorg/grinder/ns/sessions/"
  xmlns:sessiontypes="http://purl.org/openorg/grinder/ns/sessiontypes/"
>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />


  <xsl:variable name='event_name' select='/g:grinder-data/g:set[@id="event_name"]' />
  <xsl:variable name='event_homepage' select='/g:grinder-data/g:set[@id="event_homepage"]' />
  <xsl:variable name='event_city_name' select='/g:grinder-data/g:set[@id="event_city_name"]' />
  <xsl:variable name='event_city_uri' select='/g:grinder-data/g:set[@id="event_city_uri"]' />
  <xsl:variable name='event_start' select='/g:grinder-data/g:set[@id="event_start"]' />
  <xsl:variable name='event_end' select='/g:grinder-data/g:set[@id="start_end"]' />
  <xsl:variable name='event_timezone' select='/g:grinder-data/g:set[@id="event_timezone"]' />
  <xsl:variable name='event_venue_id' select='/g:grinder-data/g:set[@id="event_venue_id"]' />
  <xsl:variable name='event_twitter_username' select='/g:grinder-data/g:set[@id="event_twitter_username"]' />
  <xsl:variable name='event_twitter_hashtag' select='/g:grinder-data/g:set[@id="event_twitter_hashtag"]' />

  <xsl:variable name='programme_license_uri' select='/g:grinder-data/g:set[@id="programme_license_uri"]' />
  <xsl:variable name='programme_maintainer_id' select='/g:grinder-data/g:set[@id="programme_maintainer_id"]' />
  <xsl:variable name='programme_rdf_url' select='/g:grinder-data/g:set[@id="programme_rdf_url"]' />

  <xsl:variable name='base_uri' select='concat( $programme_rdf_url, "#" )' />



  <!-- - - - TOP LEVEL INFO - - - -->

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>
      <xsl:comment>TOP</xsl:comment>

      <rdf:Description rdf:about='{$programme_rdf_url}'>
        <foaf:primaryTopic rdf:resource='{$base_uri}event' />
        <xsl:if test="$programme_license_uri != ''">
          <dcterms:license rdf:resource="{$programme_license_uri}" />
        </xsl:if>
      </rdf:Description>

      <event:Event rdf:about="{$base_uri}event">

        <xsl:if test="$event_name != ''">
          <rdfs:label><xsl:value-of select='$event_name' /></rdfs:label>
        </xsl:if>
   
        <xsl:if test="$event_venue_id != ''">
          <event:place rdf:resource="{$base_uri}place-{$event_venue_id}"/>
        </xsl:if>
   
        <xsl:if test="$event_city_uri != ''">
          <foaf:based_near>
            <rdf:Description rdf:about="{$event_city_uri}">
              <xsl:if test="$event_city_name != ''">
                <rdfs:label><xsl:value-of select='$event_city_name' /></rdfs:label>
              </xsl:if>
            </rdf:Description>
          </foaf:based_near>
        </xsl:if>

        <xsl:if test="string($event_start) != '' and string($event_end) !=''">
          <event:time>
            <tl:Interval>
              <tl:start datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select='$event_start' /></tl:start>
              <tl:end datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select='$event_end' /></tl:end>
            </tl:Interval>
          </event:time>
        </xsl:if>

        <xsl:if test="string($event_twitter_username) != ''" >
          <foaf:account>
            <foaf:OnlineAccount>
              <foaf:accountServiceHomepage rdf:resource="http://www.twitter.com/"/>
              <foaf:accountName><xsl:value-of select='$event_twitter_username' /></foaf:accountName>
              <foaf:accountProfilePage rdf:resource="http://www.twitter.com/{$event_twitter_username}"/>
            </foaf:OnlineAccount>
          </foaf:account>
        </xsl:if>

        <xsl:if test="string($programme_maintainer_id) != ''" >
          <dcterms:creator rdf:resource="{$base_uri}person-{$programme_maintainer_id}" />
        </xsl:if>

        <xsl:if test="$event_homepage != ''">
          <foaf:homepage rdf:resource="{$event_homepage}" />
        </xsl:if>

        <prog:has_programme rdf:resource="{$base_uri}programme" />

        <xsl:if test="$event_twitter_hashtag != ''">
          <prog:twitter_hashtag><xsl:value-of select='$event_twitter_hashtag' /></prog:twitter_hashtag>
        </xsl:if>

        <!-- TODO event_timezone -->

      </event:Event>

      <prog:Programme rdf:about="{$base_uri}programme">

        <xsl:if test="$event_name != ''">
          <rdfs:label>Programme for <xsl:value-of select='$event_name' /></rdfs:label>
        </xsl:if>
        
        <xsl:apply-templates select="timeslots:row" /> 
      </prog:Programme>

      <xsl:apply-templates select="sessions:row" /> 
      <xsl:apply-templates select="locations:row" /> 
      <xsl:apply-templates select="people:row" /> 
      <xsl:apply-templates select="sessiontypes:row" /> 

    </rdf:RDF>
  </xsl:template>



  <!-- - - - TIMESLOTES - - - -->

  <xsl:template match="timeslots:row">
    <prog:has_timeslot>
      <prog:Timeslot>
        <xsl:attribute name="rdf:about" ><xsl:value-of select="$base_uri"/>timeslot-<xsl:call-template name="format-date"><xsl:with-param name="date" select='timeslots:date' /></xsl:call-template>-<xsl:call-template name="format-time"><xsl:with-param name="time" select='timeslots:start-time' /></xsl:call-template></xsl:attribute>
        <xsl:choose>
          <xsl:when test="string(timeslots:name) = ''">
            <rdfs:label><xsl:call-template name="format-time"><xsl:with-param name="time" select='timeslots:start-time' /></xsl:call-template>-<xsl:call-template name="format-time"><xsl:with-param name="time" select='timeslots:end-time' /></xsl:call-template></rdfs:label>
          </xsl:when>
          <xsl:otherwise>
            <rdfs:label><xsl:value-of select='string(timeslots:name)' /></rdfs:label>
          </xsl:otherwise>
        </xsl:choose>
        <event:time>
          <tl:Interval>
<tl:start datatype="http://www.w3.org/2001/XMLSchema#dateTime">
<xsl:call-template name="format-datetime"><xsl:with-param name="date" select='timeslots:date' /><xsl:with-param name="time" select='timeslots:start-time' /></xsl:call-template>
</tl:start>
<tl:end datatype="http://www.w3.org/2001/XMLSchema#dateTime">
<xsl:call-template name="format-datetime"><xsl:with-param name="date" select='timeslots:date' /><xsl:with-param name="time" select='timeslots:end-time' /></xsl:call-template>
</tl:end>
          </tl:Interval>
        </event:time>
      </prog:Timeslot>
    </prog:has_timeslot>
  </xsl:template>



  <!-- - - - LOCATIONS - - - -->

  <xsl:template match="locations:row">

    <xsl:if test="locations:stream/text() = 'YES'">
      <rdf:Description rdf:about="{$base_uri}programme">
        <prog:streamed_by_location rdf:resource="{$base_uri}location-{locations:location-id}" />
      </rdf:Description>
    </xsl:if>

    <geo:SpatialThing rdf:about="{$base_uri}location-{locations:location-id}">
      <xsl:if test="locations:short-name/text()">
        <rdfs:label><xsl:value-of select='locations:short-name' /></rdfs:label>
      </xsl:if>
      <xsl:if test="locations:name/text()">
        <foaf:name><xsl:value-of select='locations:name' /></foaf:name>
      </xsl:if>
      <xsl:if test="locations:within-id/text()">
        <spacerel:within rdf:resource="{$base_uri}location-{locations:within-id}" />
      </xsl:if>
      <xsl:if test="locations:latitude/text() and locations:longitude/text()">
        <geo:lat><xsl:value-of select='locations:latitude' /></geo:lat>
        <geo:long><xsl:value-of select='locations:longitude' /></geo:long>
      </xsl:if>
      <xsl:if test="locations:sameas-uri/text()">
        <owl:sameAs rdf:resource="{locations:sameas-uri}" />
      </xsl:if>
      <xsl:if test="locations:page-url/text()">
        <foaf:page rdf:resource='{locations:page-url}' />
      </xsl:if>

      <xsl:if test="locations:description/text()">
        <dcterms:description rdf:datatype='http://purl.org/xtypes/Fragment-PlainText'><xsl:value-of select='locations:description' /></dcterms:description>
      </xsl:if>
      <xsl:if test="locations:description-html/text()">
        <dcterms:description rdf:datatype='http://purl.org/xtypes/Fragment-HTML'><xsl:value-of select='locations:description' /></dcterms:description>
      </xsl:if>

      <xsl:if test="locations:type/text() = 'SITE'">
        <rdf:type rdf:resource="http://www.w3.org/ns/org#Site" />
      </xsl:if>
      <xsl:if test="locations:type/text() = 'ROOM'">
        <rdf:type rdf:resource="http://vocab.deri.ie/rooms#Room" />
      </xsl:if>
      <xsl:if test="locations:type/text() = 'BUILDING'">
        <rdf:type rdf:resource="http://vocab.deri.ie/rooms#Building" />
      </xsl:if>

      <xsl:if test="locations:twitter-hashtag/text()">
        <prog:twitter_hashtag><xsl:value-of select='locations:twitter-hashtag' /></prog:twitter_hashtag>
      </xsl:if>

      <!-- TODO <ns0:seated-capacity></ns0:seated-capacity> -->

    </geo:SpatialThing>
  </xsl:template>



  <!-- - - - SESSIONS - - - -->

  <xsl:template match="sessions:row">

    <rdf:Description rdf:about="{$base_uri}programme">
      <xsl:if test="sessions:streamed/text() = 'YES'">
        <prog:has_streamed_event rdf:resource="{$base_uri}session-{sessions:id}" />
      </xsl:if>
      <xsl:if test="sessions:streamed/text() != 'YES'">
        <prog:has_event rdf:resource="{$base_uri}session-{sessions:id}" />
      </xsl:if>
    </rdf:Description> 

    <event:Event rdf:about="{$base_uri}session-{sessions:id}">

      <xsl:if test="sessions:type != ''">
        <rdf:type rdf:resource="{$base_uri}sessiontype-{sessions:type}" />
      </xsl:if>

      <xsl:if test="sessions:short-title/text()">
        <rdfs:label><xsl:value-of select='sessions:short-title' /></rdfs:label>
      </xsl:if>

      <xsl:if test="sessions:description/text()">
        <dcterms:description rdf:datatype='http://purl.org/xtypes/Fragment-PlainText'><xsl:value-of select='sessions:description' /></dcterms:description>
      </xsl:if>
      <xsl:if test="sessions:html-description/text()">
        <dcterms:description rdf:datatype='http://purl.org/xtypes/Fragment-HTML'><xsl:value-of select='sessions:description' /></dcterms:description>
      </xsl:if>

      <xsl:if test="sessions:date != '' and sessions:start-time != '' and sessions:end-time != ''">
        <event:time><tl:Interval>
          <tl:start datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select='sessions:date' />T<xsl:value-of select='sessions:start-time' />Z</tl:start>
          <tl:end datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select='sessions:date' />T<xsl:value-of select='sessions:end-time' />Z</tl:end>
        </tl:Interval></event:time>
      </xsl:if>

      <xsl:if test="sessions:location-id != ''">
        <event:place rdf:resource="{$base_uri}location-{sessions:location-id}" />
      </xsl:if>

      <xsl:if test="sessions:page/text()">
        <foaf:page rdf:resource='{sessions:page}' />
      </xsl:if>

      <xsl:for-each select="sessions:speaker-ids">
        <prog:speaker rdf:resource="{$base_uri}person-{.}" />
      </xsl:for-each>
      <xsl:for-each select="sessions:chair-ids">
        <prog:chair rdf:resource="{$base_uri}person-{.}" />
      </xsl:for-each>
      <xsl:for-each select="sessions:panel-ids">
        <prog:panel-member rdf:resource="{$base_uri}person-{.}" />
      </xsl:for-each>

      <xsl:if test="locations:twitter-hashtag/text()">
        <prog:twitter_hashtag><xsl:value-of select='locations:twitter-hashtag' /></prog:twitter_hashtag>
      </xsl:if>

    </event:Event>

  </xsl:template>
   
     

  <!-- - - - SESSION TYPES - - - -->

  <xsl:template match="sessiontypes:row">

    <owl:Class rdf:about="{$base_uri}sessiontype-{sessiontypes:type-id}">

      <xsl:if test="sessiontypes:label/text()">
        <rdfs:label><xsl:value-of select='sessiontypes:label' /></rdfs:label>
      </xsl:if>

      <xsl:if test="sessiontypes:description/text()">
        <rdfs:comment><xsl:value-of select='sessiontypes:description' /></rdfs:comment>
      </xsl:if>

      <xsl:if test="sessiontypes:sameas-uri/text()">
        <owl:sameAs rdf:resource="{sessiontypes:sameas-uri}" />
      </xsl:if>

    </owl:Class>

  </xsl:template>



  <!-- - - - PEOPLE - - - -->

  <xsl:template match="people:row">

    <foaf:Person rdf:about="{$base_uri}person-{people:id}">

      <xsl:if test="people:given-name/text()">
        <foaf:givenName><xsl:value-of select='people:given-name' /></foaf:givenName>
      </xsl:if>
      <xsl:if test="people:family-name/text()">
        <foaf:familyName><xsl:value-of select='people:family-name' /></foaf:familyName>
      </xsl:if>
      <xsl:if test="people:given-name/text() or people:family-name/text()">
        <foaf:name><xsl:value-of select='people:given-name' /><xsl:text> </xsl:text><xsl:value-of select='people:family-name' /></foaf:name>
      </xsl:if>
      <xsl:if test="people:email/text()">
        <foaf:mbox rdf:resource="mailto:{people:email}" />
      </xsl:if>

      <xsl:if test="people:twitter-username/text()">
        <foaf:account>
          <foaf:OnlineAccount>
            <foaf:accountServiceHomepage rdf:resource="http://www.twitter.com/"/>
            <foaf:accountName><xsl:value-of select='people:twitter-username' /></foaf:accountName>
            <foaf:accountProfilePage rdf:resource="http://www.twitter.com/{people:twitter-username}"/>
          </foaf:OnlineAccount>
        </foaf:account>
      </xsl:if>

      <xsl:if test="people:blog/text()">
        <foaf:weblog rdf:resource="{people:blog}" />
      </xsl:if>
      <xsl:if test="people:homepage/text()">
        <foaf:homepage rdf:resource="{people:homepage}" />
      </xsl:if>

      <xsl:if test="people:depiction/text()">
        <foaf:depiction rdf:resource="{people:depiction}" />
      </xsl:if>

      <xsl:if test="people:bio/text()">
        <bio:biography rdf:datatype='http://purl.org/xtypes/Fragment-PlainText'><xsl:value-of select='people:bio' /></bio:biography>
      </xsl:if>
      <xsl:if test="people:html-bio/text()">
        <bio:biography rdf:datatype='http://purl.org/xtypes/Fragment-HTML'><xsl:value-of select='people:html-bio' /></bio:biography>
      </xsl:if>

      <!-- TODO: Job Title -->

      <xsl:if test="people:affiliation-url/text()">
        <foaf:workplaceHomepage rdf:resource="{people:affiliation-url}" />
      </xsl:if>
      <xsl:if test="people:affiliation-url/text() or people:affiliation-name/text() or people:job-title/text()">
        <prog:has-affiliation>
           <prog:Affiliation>
             <xsl:if test="people:job-title/text()">
               <rdfs:label><xsl:value-of select='people:job-title' /></rdfs:label>
             </xsl:if>
             <xsl:if test="people:affiliation-url/text() or people:affiliation-name/text() or people:job-title/text()">
               <prog:affiliation-to>
                 <foaf:Organization>
                   <xsl:if test="people:affiliation-name/text()">
                     <foaf:name><xsl:value-of select='people:affiliation-name' /></foaf:name>
                   </xsl:if>
                   <xsl:if test="people:affiliation-url/text()">
                     <foaf:homepage rdf:resource="{people:affiliation-url}" />
                   </xsl:if>
                 </foaf:Organization>
               </prog:affiliation-to>
             </xsl:if>
           </prog:Affiliation>
        </prog:has-affiliation>
      </xsl:if>


    </foaf:Person>


  </xsl:template>



    
  <!-- - - - MISC FUNCTIONS - - - -->

  <xsl:template name="format-datetime">
    <xsl:param name="date" />
    <xsl:param name="time" />
    <xsl:call-template name="format-date"><xsl:with-param name="date" select='$date' /></xsl:call-template> <xsl:call-template name="format-time"><xsl:with-param name="time" select='$time' /></xsl:call-template>
  </xsl:template>

  <xsl:template name="format-date">
    <xsl:param name="date" />
    <xsl:value-of select="$date" />
  </xsl:template>

  <xsl:template name="format-time">
    <xsl:param name="time" />
    <xsl:value-of select="format-number( substring-before( string($time), ':' ), '00' )" />:<xsl:value-of select="format-number( substring-before( substring-after( string($time), ':' ), ':'), '00' )" />
  </xsl:template>

  <xsl:template match="*" priority="-1">
     <xsl:comment><xsl:value-of select="concat( name(.), ': ', string(.) )" /></xsl:comment>
  </xsl:template>

</xsl:stylesheet>
