<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN"
"http://www.thecodemill.biz/repository/xql.dtd">
<!--  -->
<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2005-03-20 -->
<!-- @arch-tag: 6a8b6362-151b-499d-923c-cdb43b9fb4c1 -->
<!-- @cvs-id $Id: content-keyword-test-procs.xql,v 1.4 2015/12/04 13:49:58 cvs Exp $ -->

<queryset>
  <fullquery name="_acs-content-repository__content_keyword.confirm_delete">
    <querytext>
      select keyword_id from cr_keywords where keyword_id=:keyword_id
    </querytext>
  </fullquery>
</queryset>