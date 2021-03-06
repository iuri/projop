# /packages/intranet-timesheet2/www/hours/index.tcl
#
# Copyright (C) 1998-2004 various parties
# The code is based on ArsDigita ACS 3.4
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


ad_page_contract {
    Calendar format display of user's hours with links 
    to log more hours, if the user is looking at him/
    herself

    @param on_which_table table we're viewing hours against
    @param date day in ansi format in the month we're currently viewing
    @param julian_date day in julian format in the month we're currently viewing
    @param user_id the user for whom we're viewing hours. Defaults to currently logged in user.
    @param project_id The user group for which we're viewing hours. Defaults to all groups.
    @param return_url Return URL
 
    @author Michael Bryzek (mbryzek@arsdigita.com)
    @author Frank Bergmann (frank.bergmann@project-open.com)
    @author Klaus Hofeditz (klaus.hofeditz@project-open.com)
} {
    { date "" }
    { julian_date "" }
    { project_id:integer,multiple "" }
    { return_url "" }
    { header "" }
    { message:html "" }
    { show_week_p "" }
    { user_id_from_search "" }
}

# Decision FB on 160624: Disregard for now:
# 	Clean up data in case WF cases have been OCdeleted in WF Admin Panel. 
# 	conf_object will not be removed and hours are shown as 'to be confirmed'.
# 	db_dml sql "update im_hours set conf_object_id = null where conf_object_id not in (select object_id from wf_cases)"
# 	db_dml sql "delete from im_timesheet_conf_objects where conf_id not in (select object_id from wf_cases)"

# ---------------------------------------------------------------
# Security & Defaults
# ---------------------------------------------------------------

set current_user_id [auth::require_login]
set add_hours_all_p [im_permission $current_user_id "add_hours_all"]
set add_hours_direct_reports_p [im_permission $current_user_id "add_hours_direct_reports"]
set base_url_confirm_wf "/intranet-timesheet2-workflow/conf-objects/new-timesheet-workflow"

switch $user_id_from_search {
    "" - all - mine - direct_reports - employees - customers - providers { 
	set user_id_from_search $current_user_id 
    }
    default {
	# Is the user allowed to log hours for another user?
	if {!$add_hours_all_p} {
	    if {$add_hours_direct_reports_p} {
		set reportees [im_user_direct_reports_ids -user_id $current_user_id]
		if {[lsearch $reportees $user_id_from_search] < 0} {
		    # User not in reportees - reset to current user
		    set user_id_from_search $current_user_id 
		}
	    } else {
		# The user has no permission to log hours for others
		set user_id_from_search $current_user_id 
	    }
	}
    }
}


set user_name $user_id_from_search
if {[string is integer $user_id_from_search]} {
    set user_name [im_name_from_user_id $user_id_from_search]
}

# Eliminate "message" from return_url, which causes trouble in some places
if {"" == $return_url} {
    set return_url [ns_conn url]
    set query [export_ns_set_vars url {header message}]
    if {$query ne ""} {
        append return_url "?$query"
    }
}

set page_title [lang::message::lookup "" intranet-timesheet2.Timesheet_for_user_name "Timesheet for %user_name%"]
set context_bar [im_context_bar "[_ intranet-timesheet2.Hours]"]
set confirmation_period [parameter::get -package_id [apm_package_id_from_key intranet-timesheet2-workflow] -parameter "ConfirmationPeriod" -default "weekly"]
set fill_up_first_last_row_p [parameter::get -package_id [apm_package_id_from_key intranet-timesheet2] -parameter "FillFirstAndLastRowInTSCalendarP" -default 1]
set start_day [parameter::get -package_id [apm_package_id_from_key intranet-timesheet2] -parameter "WeekStartDay" -default 0]
set show_link_log_hours_for_week_p [parameter::get -package_id [apm_package_id_from_key intranet-timesheet2] -parameter "ShowLinkToWeeklyTimesheetP" -default 0]
set hours_base_url [parameter::get -package_id [apm_package_id_from_key intranet-timesheet2] -parameter "HourURL" -default "/intranet-timesheet2/hours"]



set header_days_of_week "";

# Patch: http://sourceforge.net/projects/project-open/forums/forum/295937/topic/3324310
for { set i $start_day } { $i < 7 } { incr i } {
    if { $i ==0 } { append header_days_of_week "[_ intranet-timesheet2.Sunday] " }
    if { $i ==1 } { append header_days_of_week "[_ intranet-timesheet2.Monday] " }
    if { $i ==2 } { append header_days_of_week "[_ intranet-timesheet2.Tuesday] " }
    if { $i ==3 } { append header_days_of_week "[_ intranet-timesheet2.Wednesday] " }
    if { $i ==4 } { append header_days_of_week "[_ intranet-timesheet2.Thursday] " }
    if { $i ==5 } { append header_days_of_week "[_ intranet-timesheet2.Friday] " }
    if { $i ==6 } { append header_days_of_week "[_ intranet-timesheet2.Saturday] " }
}
for { set i 0 } { $i < $start_day } { incr i } {
    if { $i ==0 } { append header_days_of_week "[_ intranet-timesheet2.Sunday] " }
    if { $i ==1 } { append header_days_of_week "[_ intranet-timesheet2.Monday] " }
    if { $i ==2 } { append header_days_of_week "[_ intranet-timesheet2.Tuesday] " }
    if { $i ==3 } { append header_days_of_week "[_ intranet-timesheet2.Wednesday] " }
    if { $i ==4 } { append header_days_of_week "[_ intranet-timesheet2.Thursday] " }
    if { $i ==5 } { append header_days_of_week "[_ intranet-timesheet2.Friday] " }
    if { $i ==6 } { append header_days_of_week "[_ intranet-timesheet2.Saturday] " }
}

set weekly_logging_days [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter TimesheetWeeklyLoggingDays -default "0 1 2 3 4 5 6"]

# ---------------------------------
# Date Logic: We are working with "YYYY-MM-DD" dates in this page.

if {"" ==  $date } {
    if {"" != $julian_date} {
	set date [db_string julian_date_select "select to_char( to_date(:julian_date,'J'), 'YYYY-MM-DD') from dual"]
    } else {
	set date [db_string ansi_date_select "select to_char( sysdate, 'YYYY-MM-DD') from dual"]
    }
}

set julian_date [db_string conv "select to_char(:date::date, 'J')"]
ns_log Notice "/intranet-timesheet2/index: date=$date, julian_date=$julian_date"

# Set last day of month: 
set last_day_of_month_ansi [db_string get_last_day_month "select date_trunc('month',add_months(:date,1))::date - 1" -default 0]
set first_day_of_month_ansi [db_string get_first_day_month "select date_trunc('month', '$date'::DATE)::date" -default 0]

set project_id_for_default [lindex $project_id 0]
set show_left_functional_menu_p [parameter::get_from_package_key -package_key "intranet-core" -parameter "ShowLeftFunctionalMenupP" -default 0]

# Get the project name restriction in case project_id is set
set project_restriction ""
if {[string is integer $project_id] && "" != $project_id && 0 != $project_id} {
    set project_name [db_string project_name "select project_name from im_projects where project_id = :project_id"]
    append page_title " on $project_name"
    set project_restriction "and project_id = :project_id"
}

# Append user-defined menus
set bind_vars [list user_id $current_user_id user_id_from_search $user_id_from_search julian_date $julian_date return_url $return_url show_week_p $show_week_p]
set menu_links_html [im_menu_ul_list -no_uls 1 "timesheet_hours_new_admin" $bind_vars]

# Enable the functionality to confirm timesheet hours?
set confirm_timesheet_hours_p 0
if { "" != [parameter::get -package_id [apm_package_id_from_key intranet-timesheet2-workflow] -parameter "DefaultWorkflowKey" -default ""] }  {
    set confirm_timesheet_hours_p 1
}

if {![im_column_exists im_hours conf_object_id]} { set confirm_timesheet_hours_p 0 }


# ---------------------------------------------------------------
# Render the Calendar widget
# ---------------------------------------------------------------

set calendar_details [ns_set create calendar_details]

# figure out the first and last julian days in the month
# This call defines a whole set of variables in our environment

calendar_get_info_from_db $date

# --------------------------------------------------------------
# Grab all the hours from im_hours
set sql "
	select	to_char(day, 'J') as julian_date, 
		sum(hours) as hours
	from	im_hours
	where	user_id = :user_id_from_search
		and day between to_date(:first_julian_date, 'J') and to_date(:last_julian_date, 'J') 
		$project_restriction
	group by 
		to_char(day, 'J')
"
db_foreach hours_logged $sql {
    set users_hours($julian_date) $hours
}

# --------------------------------------------------------------
# Render the calendar

set hours_for_this_week 0.0
set hours_for_this_month 0.0

set unconfirmed_hours_for_this_week 0.0
set unconfirmed_hours_for_this_month 0.0

set absence_list [absence_list_for_user_and_time_period $user_id_from_search $first_julian_date $last_julian_date]
set absence_index 0
set curr_absence ""

# Column counter runs from 1 to 7 
set column_ctr 1

# Counter for weekday -> need to correspond with weekly_logging_days
if { 1 == $start_day } {
	# Week starts with Monday 
	set week_day 1  	
} else {
	# Week starts with Sunday 
	set week_day 0
}

# Helper to determine location of last WF confirm button -> last day shown or last day of month  
set show_last_confirm_button_p 1

set timesheet_entry_blocked_p 0

# And now fill in information for every day of the month
for { set current_date $first_julian_date} { $current_date <= $last_julian_date } { incr current_date } {
   
    set current_date_ansi [dt_julian_to_ansi $current_date] 

    if { $confirm_timesheet_hours_p } {
	set no_ts_approval_wf_sql "
		select 	count(*) 
		from 	im_hours 
		where 	conf_object_id is not null 
			and day::text like '%[string range $current_date_ansi 0 9]%' 
			and user_id = :current_user_id
    	"
	set no_ts_approval_wf [db_string workflow_started_p $no_ts_approval_wf_sql -default "0"]
	if { $confirm_timesheet_hours_p && ("monthly" == $confirmation_period || "weekly" == $confirmation_period) && 0 != $no_ts_approval_wf } { 
	    ns_log Notice "TS: Entry blocked: Date: $current_date_ansi; Number: $no_ts_approval_wf; $no_ts_approval_wf_sql"
	    set timesheet_entry_blocked_p 1 
    	}
    }

    # User's hours for the day
    set hours ""
    if { [info exists users_hours($current_date)] && $users_hours($current_date) ne "" } {
 	set hours "$users_hours($current_date)  [lang::message::lookup "" intranet-timesheet2.hours "hours"]"
	set hours_for_this_week [expr {$hours_for_this_week + $users_hours($current_date)}]
	set hours_for_this_month [expr {$hours_for_this_month + $users_hours($current_date)}]
    } else {
	if { $timesheet_entry_blocked_p } {
	    set hours "<span class='log_hours'>[lang::message::lookup "" intranet-timesheet2.Nolog_Workflow_In_Progress "0 hours"]</span>"
	} else {
	    ns_log Notice "TS: Not Blocked: $current_date"
	    if { [string first $week_day $weekly_logging_days] != -1 } {
		set hours "<span class='log_hours'>[_ intranet-timesheet2.log_hours]</span>"
	    }
	}	
    }

    if {![info exists unconfirmed_hours($current_date)]} { set unconfirmed_hours($current_date) "" }
    if {"" == $unconfirmed_hours($current_date)} { set unconfirmed_hours($current_date) 0 }

    # Sum up unconfirmed_hours - KH: 160624: This might be broken and it seems that vars are not being used.  
    set unconfirmed_hours_for_this_week [expr {$unconfirmed_hours_for_this_week + $unconfirmed_hours($current_date)}]
    set unconfirmed_hours_for_this_month [expr {$unconfirmed_hours_for_this_month + $unconfirmed_hours($current_date)}]

    # User's Absences for the day
    set curr_absence [lindex $absence_list $absence_index]
    if {"" != $curr_absence} { set curr_absence "<br>$curr_absence" }

    set hours_url [export_vars -base "$hours_base_url/new" {user_id_from_search {julian_date $current_date} show_week_p return_url project_id project_id}]

    if { [string first $week_day $weekly_logging_days] != -1 } {
	set hours "<a href=$hours_url>$hours</a>"
    } else {
	set hours "$hours"
    }

    if {$column_ctr == 1 && $show_link_log_hours_for_week_p } {
	set log_hours_for_the_week_html "<br>
                <a href=[export_vars -base "$hours_base_url/new" {user_id_from_search {julian_date $current_date} {show_week_p 1} return_url}]
                ><span class='log_hours'>[lang::message::lookup "" intranet-timesheet2.Log_hours_for_the_week "Log hours for the week"]</span></a>
 	    "
    } else {
	set log_hours_for_the_week_html ""
    }

    if { [info exists users_hours($current_date)] } {
	if { [info exists unconfirmed_hours($current_date)] && $confirm_timesheet_hours_p } {
	    set no_unconfirmed_hours [get_unconfirmed_hours_for_period $user_id_from_search $current_date $current_date]  
	    if {0 == $no_unconfirmed_hours || "" == $no_unconfirmed_hours} {
		set wf_actice_case_sql "
                                select count(*)
                                from im_hours h, wf_cases c
                                where   c.object_id = h.conf_object_id and
                                        h.day::text like '%[string range [im_date_julian_to_ansi $current_date] 0 9]%' and
                                        c.state <> 'finished' and
                                        h.user_id = $user_id_from_search
                        "
		set no_wf_cases [db_string no_wf_cases $wf_actice_case_sql]
		if { $no_wf_cases > 0 } {
		    set html "<span id='hours_confirmed_yellow'>$hours</span>$curr_absence$log_hours_for_the_week_html"
		} else {
		    set html "<span id='hours_confirmed_green'>$hours</span>$curr_absence$log_hours_for_the_week_html"
		}
	    } else {
		set html "${hours}${curr_absence}<br>" 
		if {$confirm_timesheet_hours_p} {
		    append html "[lang::message::lookup "" intranet-timesheet2.ToConfirm "To confirm"]:&nbsp;"
		    append html "<span id='hours_confirmed_red'>${no_unconfirmed_hours}&nbsp;[_ intranet-timesheet2.hours]</span>"
		}	
		append html "$log_hours_for_the_week_html"
	    }
	} else {
	    set html "${hours}${curr_absence}$log_hours_for_the_week_html"
	}
    } else {
	set html "${hours}${curr_absence}$log_hours_for_the_week_html"
    }

    # ds_comment "$column_ctr, current_date_ansi: $current_date_ansi, last_day_of_month_ansi: $last_day_of_month_ansi, show_last_confirm_button_p: $show_last_confirm_button_p"

    # Render 
    if {($column_ctr == 7 || $current_date_ansi == $last_day_of_month_ansi) && $show_last_confirm_button_p } {
	append html "<br>
		<a href=[export_vars -base "week" {{julian_date $current_date} user_id_from_search}]
		>[_ intranet-timesheet2.Week_total_1] [format "%.2f" [expr {double(round(100*$hours_for_this_week))/100}]]</a><br>
	"

	if { $current_date_ansi == $last_day_of_month_ansi} { set show_last_confirm_button_p 0 }

	# Include link for weekly TS confirmation
	# Monthly confirmation_period not supported yet, always assume weekly
	# if { $confirmation_period eq "weekly" && $confirm_timesheet_hours_p } {}
	if {$confirm_timesheet_hours_p} {
	    if { !$fill_up_first_last_row_p } {
		set start_date_julian_wf [eval_wf_start_date $current_date $column_ctr]
		set end_date_julian_wf $current_date
	    } else {
		set start_date_julian_wf [expr {$current_date - 6}]
		set end_date_julian_wf $current_date    
	    }

	    set no_unconfirmed_hours [get_unconfirmed_hours_for_period $user_id_from_search $start_date_julian_wf $end_date_julian_wf]

	    # ns_log Notice "Create weekly CONFIRM button: start: $start_date_julian_wf, end: $start_date_julian_wf, No. unconfirmed Hours $no_unconfirmed_hours, confirm: $confirm_timesheet_hours_p" 
	    if {$confirm_timesheet_hours_p && (0 < $no_unconfirmed_hours || "" != $no_unconfirmed_hours) && $confirmation_period == "weekly" } {
		set conf_url [export_vars -base $base_url_confirm_wf { {user_id $user_id_from_search} {start_date_julian $start_date_julian_wf} {end_date_julian $end_date_julian_wf } return_url}]
		set button_txt [lang::message::lookup "" intranet-timesheet2.Confirm_weekly_hours "Confirm hours for this week"]
		append html "<p>&nbsp;</p><a href='$conf_url' class=button>$button_txt</a>"
	    }
        }
    }

    if { $current_date_ansi == $last_day_of_month_ansi && $confirmation_period == "monthly" } {
	set start_date_month_julian [dt_ansi_to_julian_single_arg $first_day_of_month_ansi]
	set end_date_month_julian [dt_ansi_to_julian_single_arg $last_day_of_month_ansi]
	set conf_url [export_vars -base $base_url_confirm_wf { {user_id $user_id_from_search} {start_date_julian $start_date_month_julian } {end_date_julian $end_date_month_julian}  return_url } ]
	set button_txt [lang::message::lookup "" intranet-timesheet2.Confirm_monthly_hours "Confirm hours for this month"]
	append html "<p>&nbsp;</p><a href='$conf_url' class=button>$button_txt</a>"
    } 

    ns_set put $calendar_details $current_date "$html<br>&nbsp;"
    
    # we keep track of the day of the week we are on
    incr column_ctr
    incr week_day  

    if { $column_ctr > 7 } {
	set column_ctr 1
	set hours_for_this_week 0.0
	set unconfirmed_hours_for_this_week 0.0
    }
    
    # Weekday needs to be in range [0..6]
    if { $week_day > 6 } {
	set week_day 0  
    }

    set curr_absence ""
    incr absence_index
    set timesheet_entry_blocked_p 0
}

set prev_month_template "
<font color=white>&lt;</font> 
<a href=\"[export_vars -base index {user_id_from_search}]&date=\$ansi_date\">
  <font color=white>\[_ intranet-timesheet2.$prev_month_name] </font>
</a>"
set next_month_template "
<a href=\"[export_vars -base index {user_id_from_search}]&date=\$ansi_date\">
  <font color=white>\[_ intranet-timesheet2.$next_month_name]</font>
</a> 
<font color=white>&gt;</font>"

set day_bgcolor "#efefef"
set day_number_template "<!--\$julian_date--><span class='day_number'>\$day_number</span>"

ns_log Notice "/intranet-timesheet2/index: calendar_details=$calendar_details"

set page_body [calendar_basic_month \
		   -calendar_details $calendar_details \
		   -days_of_week $header_days_of_week \
		   -next_month_template $next_month_template \
		   -prev_month_template $prev_month_template \
		   -day_number_template $day_number_template \
		   -day_bgcolor $day_bgcolor \
		   -date $date \
		   -prev_next_links_in_title 1 \
		   -fill_all_days $fill_up_first_last_row_p \
		   -empty_bgcolor "\#cccccc"]

# ---------------------------------------------------------------
# Render the Calendar widget
# ---------------------------------------------------------------

set start_date [db_string start_date "select to_char(min(day), 'YYYY-MM-01') from im_hours"]
set end_date [db_string start_date "select to_char(now()::date+31, 'YYYY-MM-01')"]
set default_date [db_list date_default "select to_char(:date::date, 'YYYY-MM-01')"]

set month_options_sql "
	select	to_char(im_day_enumerator, 'Mon YYYY') as date_pretty,
		to_char(im_day_enumerator, 'Month') as month_english,
		to_char(im_day_enumerator, 'MM') as month_of_year,
		to_char(im_day_enumerator, 'YYYY') as year,
		to_char(im_day_enumerator, 'YYYY-MM-DD') as date
	from	im_day_enumerator(:start_date::date, :end_date::date)
	where	to_char(im_day_enumerator, 'DD') = '01'
	order by
		im_day_enumerator DESC
"
set month_options [list]
set month_list_l10n [lang::message::lookup "" acs-lang.localization-mon]
regsub -all {[\{\}]} $month_list_l10n "" month_list_l10n
db_foreach months $month_options_sql {
    set month_nr [expr [string trimleft $month_of_year 0] - 1]
    set month_l10n [lindex $month_list_l10n $month_nr]
    lappend month_options [list "$month_l10n $year" $date]
}
# set month_options [db_list_of_lists month_options $month_options_sql]


set left_navbar_html "
      <div class='filter-block'>
        <div class='filter-title'>
	     [lang::message::lookup "" intranet-timesheet2.TimesheetFilters "Timesheet Filters"]
        </div>

	<form action='$hours_base_url/index' method=GET>
	[export_vars -form {show_week_p}] 
	<table border=0 cellpadding=1 cellspacing=1>
	<tr>
	    <td>[lang::message::lookup "" intranet-core.Date "Date"]</td>
	    <td>[im_select -ad_form_option_list_style_p 1 -translate_p 0 date $month_options $default_date]</td>
	</tr>
"

append left_navbar_html "
    <tr>
        <td>[lang::message::lookup "" intranet-timesheet2.Log_hours_for_user "Log Hours<br>for User"]</td>
	<td>[im_user_timesheet_hours_select user_id_from_search $user_id_from_search]</td>
    </tr>
"

append left_navbar_html "
	<tr><td></td><td><input type=submit value='Go'></td></tr>
	</table>
	</form>
      </div>
"

append left_navbar_html "
      <div class='filter-block'>
         <div class='filter-title'>
            [_ intranet-timesheet2.Other_Options]
         </div>
	 <ul>
"

# Add Absences link

if {$current_user_id != $user_id_from_search} {
    set absences_list_url [export_vars -base "/intranet-timesheet2/absences/index" {return_url user_id_from_search}]
    set absences_list_link_text [lang::message::lookup "" intranet-timesheet2.Absences_for_user_name "Absences for %user_name%"]
    append left_navbar_html "
	    <li><a href='$absences_list_url'>$absences_list_link_text</a></li>
    "
}

set add_absences_p [im_permission $current_user_id add_absences]
if {$add_absences_p} {
    set absences_url [export_vars -base "/intranet-timesheet2/absences/new" {return_url user_id_from_search}]
    set absences_link_text [lang::message::lookup "" intranet-timesheet2.Log_Absences_for_user_name "Log Absences for %user_name%"]
    append left_navbar_html "
	    <li><a href='$absences_url'>$absences_link_text</a></li>
    "
}

if {$return_url ne "" && ![regexp {^/intranet-timesheet2/hours/index} $return_url]} {
    append left_navbar_html "
	    <li><a href='$return_url'>[_ intranet-timesheet2.lt_Return_to_previous_pa]</a></li>
    "
}




# ----------------------------------------------------------
# Do we have to show administration links?
# ---------------------------------------------------------------

set admin_html ""
set links [im_menu_timesheet_admin_links]
foreach link_entry $links {
    set html ""
    for {set i 0} {$i < [llength $link_entry]} {incr i 2} {
        set name [lindex $link_entry $i]
        set url [lindex $link_entry $i+1]
        append html "<a href='$url'>$name</a>"
    }
    append admin_html "<li>$html</li>\n"
}

# Append user-defined menus
eval "set ul_links \[im_menu_ul_list -no_uls 1 \"timesheet2_timesheet\" \{user_id $current_user_id start_date_julian $first_julian_date end_date_julian $last_julian_date return_url \/intranet-timesheet2\/hours\/index\} \]"

append left_navbar_html "
	    $ul_links
	    $menu_links_html
         </ul>
      </div>
"

if {"" ne $admin_html} {
    append left_navbar_html "
      <div class='filter-block'>
         <div class='filter-title'>
            [lang::message::lookup "" intranet-core.Admin_Timesheet "Admin Timesheet"]
         </div><ul>$admin_html</ul></div>
    "
}

