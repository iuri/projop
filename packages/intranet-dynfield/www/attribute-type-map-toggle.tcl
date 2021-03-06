ad_page_contract {
    Toggle attribute display mode
    
    @author Frank Bergmann (frank.bergmann@project-open.com)
    @cvs-id $Id: attribute-type-map-toggle.tcl,v 1.2 2015/11/25 16:58:10 cvs Exp $
} {
    acs_object_type:notnull
    attribute_name:notnull
    object_type_id:integer,notnull
    display_mode:notnull
    return_url:notnull
}

set user_id [auth::require_login]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "You have insufficient privileges to use this page"
    return
}



ad_returnredirect $return_url



