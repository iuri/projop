<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN"
"http://www.thecodemill.biz/repository/xql.dtd">

<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2004-02-15 -->
<!-- @cvs-id $Id: enable.xql,v 1.3 2015/12/04 14:02:56 cvs Exp $ -->

<queryset>

  <fullquery name="enable_folder">
    <querytext>
      update dav_site_node_folder_map
      set enabled_p = 't'
      where folder_id=:id
    </querytext>
  </fullquery>
  
</queryset>