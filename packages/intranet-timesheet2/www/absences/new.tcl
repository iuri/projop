# /packages/intranet-timesheet2/www/absences/new.tcl
#
# Copyright (c) 2003-2007 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.


# Skip if this page is called as part of a Workflow panel
if {![info exists panel_p]} {
    ad_page_contract {
	@param form_mode edit or display
	@author frank.bergmann@project-open.com
	@author klaus.hofeditz@project-open.com
    } {
	absence_id:integer,optional
	{ return_url "" }
	edit_p:optional
	message:optional
	{ absence_type_id:integer 0 }
	{ form_mode "edit" }
	{ user_id_from_search "" }
    }
}

if {![info exists enable_master_p]} { set enable_master_p 1}

# ------------------------------------------------------------------
# Default & Security
# ------------------------------------------------------------------

set user_id [auth::require_login]
set current_user_id $user_id
set action_url "/intranet-timesheet2/absences/new"
set cancel_url "/intranet-timesheet2/absences/index"
set current_url [im_url_with_query]
if {"" == $return_url} { set return_url "/intranet-timesheet2/absences/index" }

set focus "absence.var_name"
set date_format "YYYY-MM-DD"
set date_time_format "YYYY MM DD"
set absence_type [lang::message::lookup "" intranet-timesheet2.Absence "Absence"]

# Custom redirect? You should change all links to this
# page to the new URL, but sometimes you miss links...
set redirect_package_url [parameter::get_from_package_key -package_key "intranet-timesheet2" -parameter "AbsenceRedirectPackageUrl" -default ""]
if {"" != $redirect_package_url} {
    ad_returnredirect "$redirect_package_url/new"
}



set absence_under_wf_control_p 0
if {[info exists absence_id]} { 
    # absence_owner_id determines the list of projects per absence and other DynField widgets
    # it defaults to user_id when creating a new absence
    set absence_owner_id [db_string absence_owner "select owner_id from im_user_absences where absence_id = :absence_id" -default ""]

    set old_absence_type_id [db_string type "select absence_type_id from im_user_absences where absence_id = :absence_id" -default 0]
    if {0 != $old_absence_type_id} { set absence_type_id $old_absence_type_id }
    set absence_type [im_category_from_id -translate_p 1 $absence_type_id]

    if {![ad_form_new_p -key absence_id]} {
	set absence_exists_p [db_string count "select count(*) from im_user_absences where absence_id=:absence_id"]
	if {!$absence_exists_p} {
	    ad_return_complaint 1 "<b>Error: The selected absence (#$absence_id) does not exist</b>:<br>The absence has probably been deleted by its owner recently."
	    ad_script_abort
	}
    }

    set absence_under_wf_control_p [db_string wf_control "
	select	count(*)
	from	wf_cases
	where	object_id = :absence_id and
		state != 'finished'
    "]
}

if {(![info exists absence_owner_id] || $absence_owner_id eq "")} { set absence_owner_id $user_id_from_search }
if {(![info exists absence_owner_id] || $absence_owner_id eq "")} { set absence_owner_id $current_user_id }

if {![info exists absence_id]} {
    set page_title [lang::message::lookup "" intranet-timesheet2.New_Absence_Type "%absence_type%"]
} else {
    set page_title [lang::message::lookup "" intranet-timesheet2.Absence_absence_type "%absence_type%"]
}

if {([info exists user_id_from_search] && $user_id_from_search ne "")} {
    set user_from_search_name [db_string name "select im_name_from_user_id(:user_id_from_search)" -default ""]
    append page_title " "
    append page_title [lang::message::lookup "" intranet-timesheet2.for_username " for %user_from_search_name%"]
}

set context [list $page_title]

set read [im_permission $current_user_id "read_absences_all"]
set write [im_permission $current_user_id "add_absences"]
set add_absences_for_group_p [im_permission $current_user_id "add_absences_for_group"]

# ad_return_complaint 1 "absence_id=$absence_id"
# ad_script_abort

if {[info exists absence_id]} {
    set absence_exists_p [db_string exists_p "select count(*) from im_user_absences where absence_id = :absence_id"]
    if {$absence_exists_p} {
	im_user_absence_permissions $current_user_id $absence_id view read write admin
    } else {
	# About to create a new absence
	set read 1
    }
}

# Check permissions
# ad_return_complaint 1 "absence_id=$absence_id, cur_uid=$current_user_id, form_mode=$form_mode, read=$read, write=$write"
switch [string tolower $form_mode] {
    display {
	if {!$read} {
	    ad_return_complaint 1 "<li>[_ intranet-timesheet2.lt_You_dont_have_suffici]"
	}
    }
    edit {
	if {!$write} {
	    ad_return_complaint 1 "<li>[lang::message::lookup "" intranet-timesheet2.No_write_permissions "You don't have permissions to modify this absence"]"
	}
    }
    default {
	ad_return_complaint 1 "<li>[lang::message::lookup "" intranet-timesheet2.Unknown_form_mode "Unknown form_mode='%form_mode%'"]"
    }
}


# Redirect if the type of the object hasn't been defined and
# if there are DynFields specific for subtypes.
if {0 == $absence_type_id && ![info exists absence_id]} {
    set all_same_p [im_dynfield::subtype_have_same_attributes_p -object_type "im_user_absence"]
    set all_same_p 0
    if {!$all_same_p} {
	ad_returnredirect [export_vars -base "/intranet/biz-object-type-select" { 
	    user_id_from_search 
	    {object_type "im_user_absence"} 
	    {return_url $current_url} 
	    {type_id_var "absence_type_id"} 
	}]
    }
}

#	    {pass_through_variables "object_type type_id_var return_url" }


# ------------------------------------------------------------------
# Action permissions
# ------------------------------------------------------------------

set actions [list]

# Check whether to show the "Edit" and "Delete" buttons.
# These buttons only make sense if the absences already exists.

if {[info exists absence_id]} {
    set absence_exists_p [db_string abs_ex "select count(*) from im_user_absences where absence_id = :absence_id"]
    if {$absence_exists_p} {

	if {$absence_under_wf_control_p} {
	    set edit_perm_func [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter AbsenceNewPageWfEditButtonPerm -default "im_absence_new_page_wf_perm_edit_button"]
	    set delete_perm_func [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter AbsenceNewPageWfDeleteButtonPerm -default "im_absence_new_page_wf_perm_delete_button"]

	    if {[eval [list $edit_perm_func -absence_id $absence_id]]} {
		lappend actions [list [lang::message::lookup {} intranet-timesheet2.Edit Edit] edit]
	    }
	    if {[eval [list $delete_perm_func -absence_id $absence_id]]} {
		lappend actions [list [lang::message::lookup {} intranet-timesheet2.Delete Delete] delete]
	    }

	} else {
	    # No workflow control - enable buttons
	    if {$write} {
		lappend actions [list [lang::message::lookup {} intranet-timesheet2.Edit Edit] edit]
	    } 
	    if {$admin} {
		lappend actions [list [lang::message::lookup {} intranet-timesheet2.Delete Delete] delete]
	    }
	}

    }
}

# ------------------------------------------------------------------
# Delete pressed?
# ------------------------------------------------------------------

set button_pressed [template::form get_action absence]
if {"delete" == $button_pressed} {
    im_user_absence_nuke $absence_id
    ad_returnredirect $return_url
}

# ------------------------------------------------------------------
# Build the form
# ------------------------------------------------------------------

set form_fields {
	absence_id:key
	{absence_owner_id:text(hidden),optional}
	{absence_name:text(text) {label "[_ intranet-timesheet2.Absence_Name]"} {html {size 40}}}
}

# -------
# By setting RequireAbsenceTypeInUrlP to '1' an 'Absence Type' can be set only by passing 
# the respective absence_type_id as an URL parameter.  
# User is provided only with links for Absence Types she's allowed to create. She won't be able 
# to edit the type anymore through the absence select box that is otherwise shown on this page.  
# A callback can be set up to prevent that users create unauthorized absences by URL manipulation.  
# For now provisional solution, RequireAbsenceTypeInUrlP is therfore a hidden parameter 
if { ![parameter::get -package_id [apm_package_id_from_key intranet-timesheet2] -parameter "RequireAbsenceTypeInUrlP" -default 0] } {
    lappend form_fields "absence_type_id:text(im_category_tree) {label \"[_ intranet-timesheet2.Type]\"} {custom {category_type \"Intranet Absence Type\" translate_p 1}}"
} 
# / -------

if {$add_absences_for_group_p} {
    set group_options_untranslated [db_list_of_lists group_options "
	select	g.group_name,
		g.group_id
	from	groups g,
		acs_objects o
	where	g.group_id = o.object_id and
		o.object_type in ('im_profile', 'im_biz_object_group')
	order by g.group_name
    "]
    set group_options [list]
    foreach tuple $group_options_untranslated {
        set gname [lindex $tuple 0]
	set gid [lindex $tuple 1]
	regsub -all {[ /]} $gname "_" gkey
	set gname [lang::message::lookup "" intranet-core.Profile_$gkey $gname]
    	lappend group_options [list $gname $gid]
    }

    #set group_options [im_profile::profile_options_all -translate_p 1]
    #ad_return_complaint 1 "$group_options <br> $group_options2"

    set group_options [linsert $group_options 0 [list "" ""]]
    lappend form_fields	{group_id:text(select),optional {label "[lang::message::lookup {} intranet-timesheet2.Valid_for_Group {Valid for Group}]"} {options $group_options}}
} else {
    # The user doesn't have the right to specify absences for groups - set group_id to NULL
    set group_id ""
}

# When Absence Type Id is expected as URL Parameter, add it to the hidden field since no select box will be shown 
set hidden_field_list [list]
if { [parameter::get -package_id [apm_package_id_from_key intranet-timesheet2] -parameter "RequireAbsenceTypeInUrlP" -default 0] } {
    lappend hidden_field_list [list absence_type_id $absence_type_id] 
    lappend hidden_field_list [list user_id $current_user_id] 
    lappend hidden_field_list [list return_url $return_url]
} else {
    lappend hidden_field_list [list user_id $current_user_id]
    lappend hidden_field_list [list return_url $return_url]
}

ad_form \
    -name absence \
    -cancel_url $cancel_url \
    -action $action_url \
    -actions $actions \
    -has_edit [expr {!$write}] \
    -mode $form_mode \
    -export $hidden_field_list \
    -form $form_fields

if {!$absence_under_wf_control_p || [im_permission $current_user_id edit_absence_status]} {
    set form_list {{absence_status_id:text(im_category_tree) {label "[lang::message::lookup {} intranet-timesheet2.Status Status]"} {custom {category_type "Intranet Absence Status" translate_p 1}}}}
} else {
    set form_list {{absence_status_id:text(hidden)}}
}

ad_form -extend -name absence -form $form_list

ad_form -extend -name absence -form {
    {start_date:date(date) {label "[_ intranet-timesheet2.Start_Date]"} {format "YYYY-MM-DD"} {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendarWithDateWidget('start_date', 'y-m-d');" >}}}
    {end_date:date(date) {label "[_ intranet-timesheet2.End_Date]"}  {help_text "[lang::message::lookup {} intranet-timesheet2.Absence_end_date_help {Last days of absence. For a one day absence please enter start date = end date.}]"}  {format "YYYY-MM-DD"} {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendarWithDateWidget('end_date', 'y-m-d');" >}}}
    {duration_days:float(text) {label "[lang::message::lookup {} intranet-timesheet2.Duration_days {Duration (Days)}]"} {help_text "[lang::message::lookup {} intranet-timesheet2.Duration_days_help {Please specify the absence duration as a number or fraction of days. Examples: '1'=one day, '0.5'=half a day}]"}}
    {description:text(textarea),optional {label "[_ intranet-timesheet2.Description]"} {html {cols 40}}}
    {contact_info:text(textarea),optional {label "[_ intranet-timesheet2.Contact_Info]"} {html {cols 40}}}
}

# ------------------------------------------------------------------
# Add DynFields
# ------------------------------------------------------------------

set my_absence_id 0
if {[info exists absence_id]} { set my_absence_id $absence_id }

set field_cnt [im_dynfield::append_attributes_to_form \
    -object_subtype_id $absence_type_id \
    -object_type "im_user_absence" \
    -form_id absence \
    -object_id $my_absence_id \
    -form_display_mode $form_mode \
]

# ------------------------------------------------------------------
# Form Actions
# ------------------------------------------------------------------

ad_form -extend -name absence -on_request {
    # Populate elements from local variables
    if {![info exists start_date]} { set start_date [db_string today "select to_char(now(), :date_time_format)"] }
    if {![info exists end_date]} { set end_date [db_string today "select to_char(now(), :date_time_format)"] }
    if {![info exists duration_days]} { set duration_days "" }
    if {![info exists absence_owner_id] || 0 == $absence_owner_id} { set absence_owner_id $user_id_from_scratch }
    if {![info exists absence_owner_id] || 0 == $absence_owner_id} { set absence_owner_id $current_user_id }
    if {![info exists absence_type_id]} { set absence_type_id [im_user_absence_type_vacation] }
    if {![info exists absence_status_id]} { set absence_status_id [im_user_absence_status_requested] }
    if {![info exists user_id_from_search]} { set user_id_from_search "" }
    if { $current_user_id != $user_id_from_search && ![im_permission $current_user_id "add_absences_all"] } {
	set user_id_from_search $current_user_id
    }
    
} -select_query {

	select	a.*,
		a.owner_id as absence_owner_id
	from	im_user_absences a
	where	absence_id = :absence_id


} -validate {

    {duration_days
	{$duration_days > 0}
	"Positive number expected"
    }
    
} -new_data {

    set start_date_sql [template::util::date get_property sql_timestamp $start_date]
    set end_date_sql [template::util::date get_property sql_timestamp $end_date]

    # Check the date range

    set date_range_error_p [db_string date_range "select $end_date_sql >= $start_date_sql"]
    if {"f" == $date_range_error_p} {
	ad_return_complaint 1 "<b>Date Range Error</b>:<br>Please revise your start and end date."
	ad_script_abort
    }

    # Check the number of absence days per interval
    set date_range_days [db_string date_range "select date($end_date_sql) - date($start_date_sql) + 1"]
    if {$duration_days > [expr {$date_range_days+1}]} {
	ad_return_complaint 1 "<b>Date Range Error</b>:<br>Duration is longer then date interval."
	ad_script_abort
    }

    if { [db_string exists "
		select	count(*) 
		from	im_user_absences a
		where	a.owner_id = :absence_owner_id and
			a.absence_type_id = :absence_type_id and
			a.start_date = $start_date_sql
	   "]
     } {
	ad_return_complaint 1 [lang::message::lookup "" intranet-timesheet2.Absence_Duplicate_Start "There is already an absence with exactly the same owner, type and start date."]
    }

    # We do not allow entries of type "Vacation" over the turn of the year in order
    # to be able to calculate vacation balance in an unambiguous manner
    if { $absence_type_id == [im_user_absence_type_vacation] && [lindex $start_date 0] != [lindex $end_date 0] } {
	set err_msg_default "Entry not allowed. Vacation absences need to begin and end in the same year. Please consider creating two entries."
	ad_return_complaint 1 [lang::message::lookup "" intranet-timesheet2.NoVacationTurnOfTheYear $err_msg_default] 
    }

    db_transaction {
	set absence_id [db_string new_absence "
		SELECT im_user_absence__new(
			:absence_id,
			'im_user_absence',
			now(),
			:current_user_id,
			'[ns_conn peeraddr]',
			null,

			:absence_name,
			:absence_owner_id,
			$start_date_sql,
			$end_date_sql,

			:absence_status_id,
			:absence_type_id,
			:description,
			:contact_info
		)
	"]

	# Don't add the creator as a participant of a group absence
	if {"" != $group_id} { set absence_owner_id "" }

	db_dml update_absence "
		UPDATE im_user_absences SET
			absence_name = :absence_name,
			owner_id = :absence_owner_id,
			start_date = $start_date_sql,
			end_date = $end_date_sql,
			duration_days = :duration_days,
			group_id = :group_id,
			absence_status_id = :absence_status_id,
			absence_type_id = :absence_type_id,
			description = :description,
			contact_info = :contact_info
		WHERE
			absence_id = :absence_id
	"

	im_dynfield::attribute_store \
	    -object_type "im_user_absence" \
	    -object_id $absence_id \
	    -form_id absence

	db_dml update_object "
		update acs_objects set
			last_modified = now(),
			modifying_user = :current_user_id,
			modifying_ip = '[ad_conn peeraddr]'
		where object_id = :absence_id
	"

	set wf_key [db_string wf "select trim(aux_string1) from im_categories where category_id = :absence_type_id" -default ""]
	set wf_exists_p [db_string wf_exists "select count(*) from wf_workflows where workflow_key = :wf_key"]
	if {$wf_exists_p} {
	    set context_key ""
	    set case_id [wf_case_new \
			     $wf_key \
			     $context_key \
			     $absence_id
			]

	    # Determine the first task in the case to be executed and start+finisch the task.
            im_workflow_skip_first_transition -case_id $case_id
	}

	# Audit the action
	im_audit -object_type im_user_absence -action after_create -object_id $absence_id -status_id $absence_status_id -type_id $absence_type_id
    }

} -edit_data {

    set start_date_sql [template::util::date get_property sql_timestamp $start_date]
    set end_date_sql [template::util::date get_property sql_timestamp $end_date]

    # Check the date range
    set date_range_error_p [db_string date_range "select $end_date_sql >= $start_date_sql"]
    if {"f" == $date_range_error_p} {
	ad_return_complaint 1 "<b>Date Range Error</b>:<br>Please revise your start and end date."
	ad_script_abort
    }

    # Check the number of absence days per interval
    set date_range_days [db_string date_range "select date($end_date_sql) - date($start_date_sql) + 1"]
    if {$duration_days > $date_range_days} {
	ad_return_complaint 1 "<b>Date Range Error</b>:<br>Duration is longer then date interval."
	ad_script_abort
    }

    # Don't add the creator as a participant of a group absence
    if {"" != $group_id} { set absence_owner_id "" }

    db_dml update_absence "
		UPDATE im_user_absences SET
			absence_name = :absence_name,
			owner_id = :absence_owner_id,
			start_date = $start_date_sql,
			end_date = $end_date_sql,
			duration_days = :duration_days,
			group_id = :group_id,
			absence_status_id = :absence_status_id,
			absence_type_id = :absence_type_id,
			description = :description,
			contact_info = :contact_info
		WHERE
			absence_id = :absence_id
    "

    im_dynfield::attribute_store \
        -object_type "im_user_absence" \
        -object_id $absence_id \
        -form_id absence

    db_dml update_object "
		update acs_objects set
			last_modified = now(),
			modifying_user = :current_user_id,
			modifying_ip = '[ad_conn peeraddr]'
		where object_id = :absence_id
    "

    # Audit the action
    im_audit -object_type im_user_absence -action after_update -object_id $absence_id -status_id $absence_status_id -type_id $absence_type_id


} -after_submit {

    ad_returnredirect $return_url
    ad_script_abort
}

