ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @author Frank Bergmann frank.bergmann@project-open.com
    @creation-date 2005-01-05
    @cvs-id $Id: widgets.tcl,v 1.6 2015/11/25 16:58:10 cvs Exp $

} {

}

# ******************************************************
# Default & Security
# ******************************************************

set page_title "Widgets"
set context_bar [im_context_bar [list /intranet-dynfield/ "DynField"] $page_title]

set user_id [auth::require_login]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "You have insufficient privileges to use this page"
    return
}

# ******************************************************
# Create the list of Widgets
# ******************************************************

set query "
	select	*,
		im_category_from_id(storage_type_id) as storage_type
	from
		im_dynfield_widgets
	order by
		lower(widget_name)
"

db_multirow widgets widgets_query $query





# ------------------------------------------------------------------
# Left Navigation Bar
# ------------------------------------------------------------------

set left_navbar_html "
            <div class=\"filter-block\">
                <div class=\"filter-title\">
                    [lang::message::lookup "" intranet-dynfield.DynField_Admin "DynField Admin"]
                </div>
		[im_dynfield::left_navbar]
            </div>
            <hr/>
"
