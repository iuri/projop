-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2005-01-06
-- @arch-tag: 15e5da0f-cfe5-48a3-a9df-80150cc47864
-- @cvs-id $Id: upgrade-5.1.4d6-5.1.4d7.sql,v 1.4 2015/12/04 13:49:58 cvs Exp $
--

select define_function_args('content_item__set_live_revision','revision_id,publish_status;ready');