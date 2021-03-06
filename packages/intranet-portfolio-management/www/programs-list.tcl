# /packages/intranet-portfolio-management/www/index.tcl
#
# Copyright (C) 1998-2013 various parties
# The software is based on ArsDigita ACS 3.4
#
# This program is free software. You can redistribute it
# and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option)
# any later version. This program is distributed in the
# hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

# ---------------------------------------------------------------
# 1. Page Contract
# ---------------------------------------------------------------

ad_page_contract { 
    List all projects with dimensional sliders.

    @param order_by project display order 
    @param start_idx the starting index for query
    @param how_many how many rows to return

    @author mbryzek@arsdigita.com
    @author frank.bergmann@project-open.com
    @author klaus.hofeditz@project-open.com

} {
    { order_by "Project nr" }
    { project_status_id 0 } 
    { letter:trim "" }
    { start_date "" }
    { end_date "" }
    { start_idx:integer 0 }
    { how_many "" }
    { view_name "program_portfolio_list" }
}

# ---------------------------------------------------------------
# 2. Defaults & Security
# ---------------------------------------------------------------

set program_enabled_p "f"
if {[catch {
    db_1row get_category_info "SELECT category_id as project_type_id, enabled_p as program_enabled_p FROM im_categories WHERE category_type = 'Intranet Project Type' and category = 'Program'" 
} err_msg]} {
    ad_return_complaint 1  "[lang::message::lookup "" intranet-core.Db_Error "DB Error"] <br> $err_msg <br>Please inform your System Administrator"
    ad_script_abort
}

if {"f" == $program_enabled_p} {
    ad_return_complaint 1 "<b>Program Management Not Enabled</b>:<br>The project type 'Program' is not enabled on this server.<br>Please inform your System Administrator"
}

# User id already verified by filters
set user_id [auth::require_login]
set admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
set subsite_id [ad_conn subsite_id]
set current_user_id $user_id
set today [lindex [split [ns_localsqltimestamp] " "] 0]
set page_title [lang::message::lookup "" intranet-portfolio-management.ProjectPrograms "Programs"] 
set context_bar [im_context_bar $page_title]
set page_focus "im_header_form.keywords"
set upper_letter [string toupper $letter]
set return_url [im_url_with_query]

# Determine the default status if not set
if { 0 == $project_status_id } {
    # Default status is open
    set project_status_id [im_project_status_open]
}

if { $how_many eq "" || $how_many < 1 } {
    set how_many [im_parameter -package_id [im_package_core_id] NumberResultsPerPage  "" 50]
}
set end_idx [expr {$start_idx + $how_many}]

# Set the "menu_select_label" for the project navbar:
# projects_open, projects_closed and projects_potential
# depending on type_id and status_id:
#
if {"" == $start_date} { set start_date [parameter::get_from_package_key -package_key "intranet-cost" -parameter DefaultStartDate -default "2000-01-01"] }
if {"" == $end_date} { set end_date [parameter::get_from_package_key -package_key "intranet-cost" -parameter DefaultEndDate -default "2100-01-01"] }

# ---------------------------------------------------------------
# 3. Defined Table Fields
# ---------------------------------------------------------------

# Define the column headers and column contents
set column_headers [list]
set column_vars [list]
set column_headers_admin [list]
set extra_selects [list]
set extra_froms [list]
set extra_wheres [list]
set view_order_by_clause ""

# Get view_id from view_name 
set view_id [db_string get_view_id "select view_id from im_views where view_name=:view_name" -default 0]

set column_sql "
select	*
from	im_view_columns
where	view_id=:view_id
	and group_id is null
order by sort_order
"

db_foreach column_list_sql $column_sql {

    set admin_html ""
    if {$admin_p} { 
	set url [export_vars -base "/intranet/admin/views/new-column" {column_id return_url}]
	set admin_html "<a href='$url'>[im_gif wrench ""]</a>" 
    }

    if {"" == $visible_for || [eval $visible_for]} {
	lappend column_headers "$column_name"
	lappend column_vars "$column_render_tcl"
	lappend column_headers_admin $admin_html
	if {"" != $extra_select} { lappend extra_selects $extra_select }
	if {"" != $extra_from} { lappend extra_froms $extra_from }
	if {"" != $extra_where} { lappend extra_wheres $extra_where }
	if {"" != $order_by_clause &&
	    $order_by==$column_name} {
	    set view_order_by_clause $order_by_clause
	}
    }
}

# ---------------------------------------------------------------
# Filter with Dynamic Fields
# ---------------------------------------------------------------

set form_id "project_filter"
set object_type "im_project"
set action_url "/intranet-portfolio-management/index"
set form_mode "edit"

ad_form \
    -name $form_id \
    -action $action_url \
    -mode $form_mode \
    -method GET \
    -export {start_idx order_by how_many view_name include_subprojects_p include_subproject_level letter}\
    -form {}


    ad_form -extend -name $form_id -form {
        {project_status_id:text(im_category_tree),optional {label \#intranet-portfolio-management.ProgramStatus\#} {value $project_status_id} {custom {category_type "Intranet Project Status" translate_p 1}} }
    } 

# Project Type, Start/End Date
ad_form -extend -name $form_id -form {
    {start_date:text(text) {label "[_ intranet-timesheet2.Start_Date]"} {value "$start_date"} {html {size 10}} {after_html {<input type="button" style="height:20px; width:20px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendar('start_date', 'y-m-d');" >}}}
    {end_date:text(text) {label "[_ intranet-timesheet2.End_Date]"} {value "$end_date"} {html {size 10}} {after_html {<input type="button" style="height:20px; width:20px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendar('end_date', 'y-m-d');" >}}}
}

set filter_admin_html ""


# ---------------------------------------------------------------
# 5. Generate SQL Query
# ---------------------------------------------------------------

set criteria [list]
if { $project_status_id ne "" && $project_status_id > 0 } {
    lappend criteria "p.project_status_id in ([join [im_sub_categories $project_status_id] ","])"
}
if { $project_type_id ne "" && $project_type_id != 0 } {
    lappend criteria "p.project_type_id in ([join [im_sub_categories $project_type_id] ","])"
}

if {"" != $start_date} {
    lappend criteria "p.end_date >= :start_date::timestamptz"
}
if {"" != $end_date} {
    lappend criteria "p.start_date < :end_date::timestamptz"
}


set order_by_clause "order by lower(project_nr) DESC"
switch [string tolower $order_by] {
    "start date" { set order_by_clause "order by start_date DESC" }
    "delivery date" { set order_by_clause "order by end_date" }
    "project nr" { set order_by_clause "order by project_nr desc" }
    "project name" { set order_by_clause "order by lower(project_name)" }
    default {
	if {$view_order_by_clause ne ""} {
	    set order_by_clause "order by $view_order_by_clause"
	}
    }
}

set where_clause [join $criteria " and\n            "]
if { $where_clause ne "" } {
    set where_clause " and $where_clause"
}

set extra_select [join $extra_selects ",\n\t"]
if { $extra_select ne "" } {
    set extra_select ",\n\t$extra_select"
}

set extra_from [join $extra_froms ",\n\t"]
if { $extra_from ne "" } {
    set extra_from ",\n\t$extra_from"
}

set extra_where [join $extra_wheres "and\n\t"]
if { $extra_where ne "" } {
    set extra_where ",\n\t$extra_where"
}


# Create a ns_set with all local variables in order
# to pass it to the SQL query
set form_vars [ns_set create]
foreach varname [info locals] {
    # Don't consider variables that start with a "_", that
    # contain a ":" or that are array variables:
    if {"_" == [string range $varname 0 0]} { continue }
    if {[regexp {:} $varname]} { continue }
    if {[array exists $varname]} { continue }

    # Get the value of the variable and add to the form_vars set
    set value [expr "\$$varname"]
    ns_set put $form_vars $varname $value
}


# Deal with DynField Vars and add constraint to SQL
#
set filter_advanced_p 0
if {$filter_advanced_p} {
    set dynfield_extra_where $extra_sql_array(where)
    set ns_set_vars $extra_sql_array(bind_vars)
    set tmp_vars [util_list_to_ns_set $ns_set_vars]
    set tmp_var_size [ns_set size $tmp_vars]
    for {set i 0} {$i < $tmp_var_size} { incr i } {
	set key [ns_set key $tmp_vars $i]
	set value [ns_set get $tmp_vars $key]
	ns_set put $form_vars $key $value
    }
    # Add the additional condition to the "where_clause"
    if {"" != $dynfield_extra_where} {
	append where_clause "
	    and project_id in $dynfield_extra_where
        "
    }
}

set sql "
SELECT *
FROM
        ( SELECT
                p.*,
                im_name_from_user_id(project_lead_id) as lead_name,
                im_category_from_id(p.project_type_id) as project_type,
                im_category_from_id(p.project_status_id) as project_status,
                to_char(p.start_date, 'YYYY-MM-DD') as start_date_formatted,
                to_char(p.end_date, 'YYYY-MM-DD') as end_date_formatted,
                to_char(p.end_date, 'HH24:MI') as end_date_time
		$extra_select
        FROM
                im_projects p
		$extra_from
        WHERE
		p.project_type_id not in ([im_project_type_task], [im_project_type_ticket])
                $where_clause
		$extra_where
        ) projects
$order_by_clause
"

# ---------------------------------------------------------------
# 5a. Limit the SQL query to MAX rows and provide << and >>
# ---------------------------------------------------------------

# Limit the search results to N data sets only
# to be able to manage large sites
#

ns_log Notice "/intranet/project/index: Before limiting clause"

if {$upper_letter eq "ALL"} {
    # Set these limits to negative values to deactivate them
    set total_in_limited -1
    set how_many -1
    set selection $sql
} else {
    # We can't get around counting in advance if we want to be able to
    # sort inside the table on the page for only those users in the
    # query results
    set total_in_limited [db_string total_in_limited "
        select count(*)
        from ($sql) s
    "]

    # Special case: FIRST the users selected the 2nd page of the results
    # and THEN added a filter. Let's reset the results for this case:
    while {$start_idx > 0 && $total_in_limited < $start_idx} {
	set start_idx [expr {$start_idx - $how_many}]
	set end_idx [expr {$end_idx - $how_many}]
    }

    set selection [im_select_row_range $sql $start_idx $end_idx]
}	

# ---------------------------------------------------------------
# 6. Format the Filter
# ---------------------------------------------------------------

# Note that we use a nested table because im_slider might
# return a table with a form in it (if there are too many
# options

ns_log Notice "/intranet/project/index: Before formatting filter"

set letter $upper_letter

# ----------------------------------------------------------
# Do we have to show administration links?

ns_log Notice "/intranet/project/index: Before admin links"
set admin_html "<ul>"

if {[im_permission $current_user_id "add_projects"]} {
    append admin_html "<li><a href=\"/intranet/projects/new\">[_ intranet-core.Add_a_new_project]</a>\n"

    set new_from_template_p [im_parameter -package_id [im_package_core_id] EnableNewFromTemplateLinkP "" 0]
    if {$new_from_template_p} {
        append admin_html "<li><a href=\"/intranet/projects/new-from-template\">[lang::message::lookup "" intranet-core.Add_a_new_project_from_Template "Add a new project from Template"]</a>\n"
    }

    set wf_oid_col_exists_p [im_column_exists wf_workflows object_type]
    if {$wf_oid_col_exists_p} {
	set wf_sql "
		select	t.pretty_name as wf_name,
			w.*
		from	wf_workflows w,
			acs_object_types t
		where	w.workflow_key = t.object_type
			and w.object_type = 'im_project'
	"
	db_foreach wfs $wf_sql {
	    set new_from_wf_url [export_vars -base "/intranet/projects/new" {workflow_key}]
	    append admin_html "<li><a href=\"$new_from_wf_url\">[lang::message::lookup "" intranet-core.New_workflow "New %wf_name%"]</a>\n"
	}
    }
}

# Append user-defined menus
set bind_vars [list return_url $return_url]
append admin_html [im_menu_ul_list -no_uls 1 "projects_admin" $bind_vars]
append admin_html "</ul>"
set admin_html ""

# ---------------------------------------------------------------
# 7. Format the List Table Header
# ---------------------------------------------------------------

# Set up colspan to be the number of headers + 1 for the # column
ns_log Notice "/intranet/project-portfolio-management/index: Before format header"
set colspan [expr {[llength $column_headers] + 1}]

set table_header_html ""

# Format the header names with links that modify the
# sort order of the SQL query.
#
set url "index?"
set query_string [export_ns_set_vars url [list order_by]]
if { $query_string ne "" } {
    append url "$query_string&"
}

append table_header_html "<tr>\n"
set ctr 0
foreach col $column_headers {
    set wrench_html [lindex $column_headers_admin $ctr]
    regsub -all " " $col "_" col_txt
    set col_txt [lang::message::lookup "" intranet-core.$col_txt $col]
    if {$order_by eq $col } {
	append table_header_html "<td class=rowtitle>$col_txt$wrench_html</td>\n"
    } else {
	#set col [lang::util::suggest_key $col]
	append table_header_html "<td class=rowtitle><a href=\"${url}order_by=[ns_urlencode $col]\">$col_txt</a>$wrench_html</td>\n"
    }
    incr ctr
}
append table_header_html "</tr>\n"


# ---------------------------------------------------------------
# 8. Format the Result Data
# ---------------------------------------------------------------

ns_log Notice "/intranet/project/index: Before db_foreach"

set table_body_html ""
set bgcolor(0) " class=roweven "
set bgcolor(1) " class=rowodd "
set ctr 0
set idx $start_idx

db_foreach projects_info_query $selection -bind $form_vars {

    # Gif for collapsable tree?
    set gif_html ""

    set url [im_maybe_prepend_http $url]
    if { $url eq "" } {
	set url_string "&nbsp;"
    } else {
	set url_string "<a href=\"$url\">$url</a>"
    }

    # Append together a line of data based on the "column_vars" parameter list
    set row_html "<tr$bgcolor([expr {$ctr % 2}])>\n"
    foreach column_var $column_vars {
	append row_html "\t<td valign=top>"
	set cmd "append row_html $column_var"
	if {[catch {
	    eval "$cmd"
	} errmsg]} {
            # TODO: warn user
	}
	append row_html "</td>\n"
    }
    append row_html "</tr>\n"
    append table_body_html $row_html

    incr ctr
    if { $how_many > 0 && $ctr > $how_many } {
	break
    }
    incr idx
}

# Show a reasonable message when there are no result rows:
if { $table_body_html eq "" } {
    set table_body_html "
        <tr><td colspan=$colspan><ul><li><b> 
	[lang::message::lookup "" intranet-core.lt_There_are_currently_n "There are currently no entries matching the selected criteria"]
        </b></ul></td></tr>"
}

if { $end_idx < $total_in_limited } {
    # This means that there are rows that we decided not to return
    # Include a link to go to the next page
    set next_start_idx [expr {$end_idx + 0}]
    set next_page_url "index?start_idx=$next_start_idx&amp;[export_ns_set_vars url [list start_idx]]"
} else {
    set next_page_url ""
}

if { $start_idx > 0 } {
    # This means we didn't start with the first row - there is
    # at least 1 previous row. add a previous page link
    set previous_start_idx [expr {$start_idx - $how_many}]
    if { $previous_start_idx < 0 } { set previous_start_idx 0 }
    set previous_page_url "index?start_idx=$previous_start_idx&amp;[export_ns_set_vars url [list start_idx]]"
} else {
    set previous_page_url ""
}

# ---------------------------------------------------------------
# 9. Format Table Continuation
# ---------------------------------------------------------------

ns_log Notice "/intranet/project/index: before table continuation"
# Check if there are rows that we decided not to return
# => include a link to go to the next page
#
if {$total_in_limited > 0 && $end_idx < $total_in_limited} {
    set next_start_idx [expr {$end_idx + 0}]
    set next_page "<a href=index?start_idx=$next_start_idx&amp;[export_ns_set_vars url [list start_idx]]>Next Page</a>"
} else {
    set next_page ""
}

# Check if this is the continuation of a table (we didn't start with the
# first row - there is at least 1 previous row.
# => add a previous page link
#
if { $start_idx > 0 } {
    set previous_start_idx [expr {$start_idx - $how_many}]
    if { $previous_start_idx < 0 } { set previous_start_idx 0 }
    set previous_page "<a href=index?start_idx=$previous_start_idx&amp;[export_ns_set_vars url [list start_idx]]>Previous Page</a>"
} else {
    set previous_page ""
}

set table_continuation_html "
<tr>
  <td align=center colspan=$colspan>
    [im_maybe_insert_link $previous_page $next_page]
  </td>
</tr>"


# ---------------------------------------------------------------
# Navbars
# ---------------------------------------------------------------

# Get the URL variables for pass-though
set query_pieces [split [ns_conn query] "&"]
set pass_through_vars [list]
foreach query_piece $query_pieces {
    if {[regexp {^([^=]+)=(.+)$} $query_piece match var val]} {
	# exclude "form:...", "__varname" and "letter" variables
	if {[regexp {^form} $var match]} {continue}
	if {[regexp {^__} $var match]} {continue}
	if {[regexp {^letter$} $var match]} {continue}
	set var [ns_urldecode $var]
	lappend pass_through_vars $var
    }
}

#
set letter $upper_letter

# Compile and execute the formtemplate if advanced filtering is enabled.
eval [template::adp_compile -string {<formtemplate id="project_filter" style="tiny-plain-po"></formtemplate>}]
set filter_html $__adp_output

# Left Navbar is the filter/select part of the left bar
set left_navbar_html "
	<div class='filter-block'>
        	<div class='filter-title'>
	           [_ intranet-portfolio-management.FilterPrograms] $filter_admin_html
        	</div>
            	$filter_html
      	</div>
"

set program_table_inner_html "
	<table class='table_list_page'>
       $table_header_html
       $table_body_html 
       $table_continuation_html
	</table>
"
set program_table_html [im_table_with_title [lang::message::lookup "" intranet-portfolio-management.Programs "Programs"] $program_table_inner_html]
