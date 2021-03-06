# /packages/intranet-timesheet2/www/dedication_days_pr.tcl
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
    Purpose: See the employees project dedication status

    @author jruiz@competitiveness.com
    @creation-date May 2003
} {
    {from_date:array,date ""}
    {to_date:array,date ""}
    { project "" }
    { report_pr_p "" }
}
# user_id already validated by /intranet filters
set user_id [ad_conn user_id]
set user_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]

set date_format "YYYY-MM-DD"

set form [ns_conn form]
if {$form eq ""} {
    set form [ns_set new]
}
set start [validate_ad_dateentrywidget from_date from_date $form allownull]
if { $start eq "" } {
    set start "2000-01-01"
}
set end [validate_ad_dateentrywidget to_date to_date $form allownull]
if { $end eq "" } {
    set end [db_string sysdate \
            "select to_char(sysdate,'YYYY-MM-DD') from dual"]
}

# Default status is OPEN - with the id '77'
if { $report_pr_p eq "y" } {
    set sql_filters "  and pr.project_status_id = '77' \
	                  and pr.requires_report_p = 't'"
    set check "checked"
} else {
    set sql_filters " and pr.project_status_id = '77'"
    set check ""
}


set page_title "[_ intranet-timesheet2.lt_Dedication_days_repor]"
set context_bar [im_context_bar [list /intranet/ "[_ intranet-timesheet2.Your_workspace]"] "[_ intranet-timesheet2.lt_Dedication_days_repor]"]

append page_body "[_ intranet-timesheet2.lt_To_send_proyect_infor]<a href=send_pr_info>[_ intranet-timesheet2.here]</a>."

set project_list [db_list_of_lists get_projects "select pr.group_id as project, \
	                                               ug.short_name as name \
						       from IM_PROJECTS pr, USER_GROUPS ug \
						       where pr.group_id = ug.group_id \
						       order by name"]

set pr_filter [cm_co_define -default $project -first_item [list [list "" "[_ intranet-timesheet2.All_projects]"]] project $project_list]

append page_body "
<form method=POST>
$pr_filter <br>
[_ intranet-timesheet2.lt_Show_only_projects_wi]<input type=checkbox name=report_pr_p value=y $check>
&nbsp; [_ intranet-timesheet2.from][ad_dateentrywidget from_date $start] &nbsp;[_ intranet-timesheet2.to][ad_dateentrywidget to_date $end]
<input type=submit value='[_ intranet-timesheet2.go]'>
</form>
<table border=0 cellpadding=3 cellspacing=0>
  <tr>
    <td colspan=2>&nbsp;</td>
    <td class=titlerow colspan=4 align=center>[_ intranet-timesheet2.DAYS]</td>
    <td colspan=1>&nbsp;</td>
    <td class=titlerow colspan=4 align=center>[_ intranet-timesheet2.AMOUNTS]</td>
  </tr>
  <tr>
    <td class=titlerow>[_ intranet-timesheet2.Case]</td>
    <td class=titlerow>[_ intranet-timesheet2.Employee]</td>
    <td class=titlerow align=center>[_ intranet-timesheet2.Budget]</td>
    <td class=titlerow align=center>[_ intranet-timesheet2.Real]</td>
    <td class=titlerow align=center><font color=red>[_ intranet-timesheet2.Deviation]<font></td>
    <td class=titlerow align=center>%</td>
    <td class=titlerow>&nbsp;</td>
    <td class=titlerow align=center>[_ intranet-timesheet2.Budget]</td>
    <td class=titlerow align=center>[_ intranet-timesheet2.Real]</td>
    <td class=titlerow align=center><font color=red>[_ intranet-timesheet2.Deviation]</font></td>
    <td class=titlerow align=center>%</td>
  </tr>"

db_release_unused_handles

if { $project ne "" } {
    set sql_filters " and pr.group_id=:project"
    set project_id $project
}

set sql_projects "select pr.group_id as project_id, \
	ug.short_name as project_name \
	from IM_PROJECTS pr, USER_GROUPS ug \
	where pr.group_id = ug.group_id \
	$sql_filters \
	order by project_name"

db_foreach projects $sql_projects {
    set sql_query "select rownum, employee_id, emp_name from \
	             (select rownum, \
	                     u.user_id as employee_id, \
			     SUBSTR(u.email, 0, INSTR(u.email,'@')-1) as emp_name \
		      from USERS u, USER_GROUP_MAP ugm \
		      where ugm.group_id = :project_id \
		      and u.user_id = ugm.user_id \
		      order by emp_name)"

    set sum_days "0"
    set sum_real_days "0"
    set sum_cost "0"
    set sum_real_cost "0"

    db_foreach get_user_projects $sql_query {
        append page_body "<tr>"
        if { $rownum == 1 } {
            append page_body "<td class=row[expr {$rownum%2}]><b>$project_name</b></td>"
        } else {
            append page_body "<td class=row[expr {$rownum%2}]>&nbsp;</td>"
        }

        set days [db_string g_days "select TO_CHAR(NVL(field_value,0),'999990D9') \
                                    from USER_GROUP_MEMBER_FIELD_MAP \
                                    where group_id=:project_id \
                                    and user_id=:employee_id \
                                    and field_name='estimation_days'" -default "0.0"]
        set day_cost [db_string g_cost "select TO_CHAR(NVL(field_value,0),'999990') \
                                    from USER_GROUP_MEMBER_FIELD_MAP \
                                    where group_id=:project_id \
                                    and user_id=:employee_id \
                                    and field_name='cost_per_day'" -default "0"]
        set real_days [db_string g_r_days "select TO_CHAR(NVL(SUM(hours)/10,0),'999990D9') \
                                           from IM_HOURS \
                                           where on_what_id=:project_id \
                                           and user_id=:employee_id \
                                           and day between to_date('$start',:date_format)
                                                       and to_date('$end',:date_format)" -default "0.0"]

        set days_diff [expr {$days - $real_days}]
        set cost [format "%0.0f" [expr {$days * $day_cost}]]
        set real_cost [format "%0.0f" [expr {$real_days * $day_cost}]]
        set cost_diff [format "%0.0f" [expr {$cost - $real_cost}]]

        if { $days_diff < 0 } {
            set days_diff_color " style=\"color:red\" "
        } else {
            set days_diff_color " style=\"color:blue\" "
        }
        if { $cost_diff < 0 } {
            set cost_diff_color " style=\"color:red\" "
        } else {
            set cost_diff_color " style=\"color:blue\" "
        }
        if { $days == 0 } {
            set per_days "NaN"
        } else {
            set per_days [format "%0.2f" [expr {[expr {$days_diff / $days}] * 100}]]%
        }
        if { $cost == 0 } {
            set per_cost "NaN"
        } else {
            set per_cost [format "%0.2f" [expr {[expr {$cost_diff.0 / $cost}] * 100}]]%
        }

	append page_body "
        <td class=row[expr {$rownum%2}]>$emp_name</td>
        <td class=row[expr {$rownum%2}] align=right>$days</td>
        <td class=row[expr {$rownum%2}] align=right>$real_days</td>
        <td class=row[expr {$rownum%2}] align=right $days_diff_color>$days_diff</td>
        <td class=row[expr {$rownum%2}] align=right $days_diff_color>$per_days</td>
        <td class=row[expr {$rownum%2}]>&nbsp;</td>
        <td class=row[expr {$rownum%2}] align=right>$cost</td>
        <td class=row[expr {$rownum%2}] align=right>$real_cost</td>
        <td class=row[expr {$rownum%2}] align=right $cost_diff_color>$cost_diff</td>
        <td class=row[expr {$rownum%2}] align=right $cost_diff_color>$per_cost</td>
        </tr>"
	
        set sum_days [expr {$sum_days + $days}]
        set sum_cost [expr {$sum_cost + $cost}]
        set sum_real_days [expr {$sum_real_days + $real_days}]
        set sum_real_cost [expr {$sum_real_cost + $real_cost}]
    }

    set sum_days_diff [expr {$sum_days - $sum_real_days}]
    set sum_cost_diff [expr {$sum_cost - $sum_real_cost}]
    if { $sum_days_diff < 0 } {
            set sum_days_color " style=\"color:red\" "
    } else {
            set sum_days_color ""
    }
    if { $sum_cost_diff < 0 } {
            set sum_cost_color " style=\"color:red\" "
    } else {
            set sum_cost_color ""
    }
    if { $sum_days == 0 } {
            set per_sum_days "NaN"
    } else {
            set per_sum_days [format "%0.2f" [expr {[expr {$sum_days_diff / $sum_days}] * 100}]]%
    }
    if { $sum_cost == 0 } {
            set per_sum_cost "NaN"
    } else {
            set per_sum_cost [format "%0.2f" [expr {[expr {$sum_cost_diff.0 / $sum_cost}] * 100}]]%
    }

    append page_body "    
    <tr>
    <td class=titlerow>&nbsp;</td>
    <td class=titlerow><b><i>[_ intranet-timesheet2.Total]</i></b></td>
    <td class=titlerow align=right><i>$sum_days</i></td>
    <td class=titlerow align=right><i>$sum_real_days</i></td>
    <td class=titlerow align=right $sum_days_color><i>$sum_days_diff</i></td>
    <td class=titlerow align=right $sum_days_color><i>$per_sum_days</i></td>
    <td class=titlerow>&nbsp;</td>
    <td class=titlerow align=right><i>$sum_cost</i></td>
    <td class=titlerow align=right><i>$sum_real_cost</i></td>
    <td class=titlerow align=right $sum_cost_color><i>$sum_cost_diff</i></td>
    <td class=titlerow align=right $sum_cost_color><b>$per_sum_cost</b></td>
    </tr>
    <tr>    <td colspan=6>[im_pushbar 1 2]</td>    </tr>"

}
 
append page_body "    </table>"

doc_return  200 text/html [im_return_template]
